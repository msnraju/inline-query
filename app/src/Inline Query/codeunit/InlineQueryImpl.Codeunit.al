codeunit 50101 "Inline Query Impl"
{
    Access = Internal;

    var
        InlineQueryTokenizer: Codeunit "Inline Query Tokenizer";
        InlineQueryParser: Codeunit "Inline Query Parser";
        InlineQueryCompiler: Codeunit "Inline Query Compiler";
        EmptyQueryErr: Label 'Query should not be empty.';
        FunctionExpectedErr: Label 'Function expected.';
        SingleFunctionExpectedErr: Label 'A single function expected.';
        AggregateFunctionsErr: Label 'Cannot use aggregate columns in this method.';
        SortingLbl: Label 'SORTING(%1)', Locked = true, Comment = '%1 = Field';
        SpecialCharsTxt: Label ' ~!@#$%^&*()-+={[}]|\:;"''<,>.?/', Locked = true;
        AggregateExprExpectedErr: Label 'Aggregate expression expected for Field %1', Comment = '%1 = Field Name';

    procedure AsInteger(QueryText: Text): Integer
    var
        ValueVariant: Variant;
    begin
        AsVariant(QueryText, ValueVariant);
        exit(ValueVariant);
    end;

    procedure AsBigInteger(QueryText: Text): BigInteger
    var
        ValueVariant: Variant;
    begin
        AsVariant(QueryText, ValueVariant);
        exit(ValueVariant);
    end;

    procedure AsCode(QueryText: Text): Code[2048]
    var
        ValueVariant: Variant;
    begin
        AsVariant(QueryText, ValueVariant);
        exit(ValueVariant);
    end;

    procedure AsDateTime(QueryText: Text): DateTime
    var
        ValueVariant: Variant;
    begin
        AsVariant(QueryText, ValueVariant);
        exit(ValueVariant);
    end;

    procedure AsTime(QueryText: Text): Time
    var
        ValueVariant: Variant;
    begin
        AsVariant(QueryText, ValueVariant);
        exit(ValueVariant);
    end;

    procedure AsBoolean(QueryText: Text): Boolean
    var
        ValueVariant: Variant;
    begin
        AsVariant(QueryText, ValueVariant);
        exit(ValueVariant);
    end;

    procedure AsDate(QueryText: Text): Date
    var
        ValueVariant: Variant;
    begin
        AsVariant(QueryText, ValueVariant);
        exit(ValueVariant);
    end;

    procedure AsDecimal(QueryText: Text): Decimal
    var
        ValueVariant: Variant;
    begin
        AsVariant(QueryText, ValueVariant);
        exit(ValueVariant);
    end;

    procedure AsText(QueryText: Text): Text
    var
        ValueVariant: Variant;
    begin
        AsVariant(QueryText, ValueVariant);
        exit(ValueVariant);
    end;

    procedure AsVariant(QueryText: Text; var ValueVariant: Variant)
    var
        RecordRef: RecordRef;
        JASTNode: JsonObject;
    begin
        JASTNode := QueryAsASTNode(QueryText);
        PrepareRecRef(RecordRef, JASTNode);
        GetFunctionValue(RecordRef, JASTNode, ValueVariant);
    end;

    procedure AsRecord(QueryText: Text; var RecordRef: RecordRef)
    var
        JASTNode: JsonObject;
    begin
        JASTNode := QueryAsASTNode(QueryText);
        if HasColumnFunctions(JASTNode) then
            Error(AggregateFunctionsErr);

        PrepareRecRef(RecordRef, JASTNode);
    end;

    procedure AsJsonArray(QueryText: Text): JsonArray
    var
        JFieldHeaders: JsonArray;
    begin
        exit(AsJsonArray(QueryText, JFieldHeaders, false));
    end;

    procedure AsJsonArray(QueryText: Text; JFieldHeaders: JsonArray; UseNames: Boolean): JsonArray
    var
        RecordRef: RecordRef;
        JASTNode: JsonObject;
        JToken: JsonToken;
        Top: Integer;
    begin
        JASTNode := QueryAsASTNode(QueryText);
        if HasColumnFunctions(JASTNode) then
            exit(FunctionValuesAsJson(JASTNode, JFieldHeaders));

        PrepareRecRef(RecordRef, JASTNode, JFieldHeaders);

        if JASTNode.Get('Top', JToken) then
            Top := JToken.AsValue().AsInteger();

        if not JASTNode.Get('Fields', JToken) then
            exit;

        exit(Records2Json(RecordRef, JToken.AsArray(), Top, UseNames))
    end;

    local procedure FunctionValuesAsJson(JASTNode: JsonObject; JFieldHeaders: JsonArray): JsonArray
    var
        RecordRef: RecordRef;
        JFieldHeaders2: JsonArray;
        JToken: JsonToken;
        JFields: JsonArray;
        JRecords: JsonArray;
        JRecord: JsonObject;
        JField: JsonObject;
    begin
        PrepareRecRef(RecordRef, JASTNode, JFieldHeaders2);
        JASTNode.Get('Fields', JToken);
        JFields := JToken.AsArray();
        foreach JToken in JFields do begin
            JField := JToken.AsObject();
            FunctionValueAsJson(RecordRef, JASTNode, JRecord, JField, JFieldHeaders);
        end;

        JRecords.Add(JRecord);
        exit(JRecords);
    end;

    local procedure FunctionValueAsJson(
        RecordRef: RecordRef;
        JASTNode: JsonObject;
        JRecord: JsonObject;
        JField: JsonObject;
        JFieldHeaders: JsonArray)
    var
        FieldRef: FieldRef;
        JToken: JsonToken;
        ValueVariant: Variant;
        JFieldHeader: JsonObject;
        FieldID: Integer;
        FieldName: Text;
        IsFunction: Boolean;
        FunctionType: Enum "Inline Query Function Type";
    begin
        AggregateFieldValue(RecordRef, JASTNode, JField, ValueVariant);
        JField.Get('Name', JToken);
        FieldName := JToken.AsValue().AsText();

        JField.Get('Field', JToken);
        FieldID := JToken.AsValue().AsInteger();

        JField.Get('IsFunction', JToken);
        IsFunction := JToken.AsValue().AsBoolean();
        if not IsFunction then
            Error(AggregateExprExpectedErr, FieldName);

        JField.Get('Function', JToken);
        FunctionType := "Inline Query Function Type".FromInteger(JToken.AsValue().AsInteger());

        if FieldName = '' then
            if FieldID <> 0 then begin
                FieldRef := RecordRef.Field(FieldID);
                FieldName := Format(FunctionType) + ' of ' + FieldRef.Name;
            end else
                FieldName := Format(FunctionType);

        JFieldHeader.Add('Caption', FieldName);
        FieldName := ConvertStr(FieldName, SpecialCharsTxt, PadStr('', StrLen(SpecialCharsTxt), '_'));
        JFieldHeader.Add('Name', FieldName);
        JFieldHeaders.Add(JFieldHeader);

        JRecord.Add(FieldName, Format(ValueVariant));
    end;

    local procedure Records2Json(var RecordRef: RecordRef; JFields: JsonArray; Top: Integer; UseNames: Boolean): JsonArray
    var
        JRecords: JsonArray;
        Counter: Integer;
    begin
        if RecordRef.FindSet() then
            repeat
                Counter += 1;
                JRecords.Add(Record2Json(RecordRef, JFields, UseNames));

                if (Top <> 0) and (Counter >= Top) then
                    Break;
            until RecordRef.Next() = 0;

        exit(JRecords);
    end;

    local procedure Record2Json(var RecordRef: RecordRef; JFields: JsonArray; UseNames: Boolean): JsonObject
    var
        Field: Record Field;
        FieldRef: FieldRef;
        JRecord: JsonObject;
        JToken: JsonToken;
        JField: JsonObject;
        FieldID: Integer;
        IsFunction: Boolean;
        FieldName: Text;
    begin
        foreach JToken in JFields do begin
            JField := JToken.AsObject();
            JField.Get('Field', JToken);
            FieldName := JToken.AsValue().AsText();

            if JField.Get('IsFunction', JToken) then
                IsFunction := JToken.AsValue().AsBoolean();

            if (not IsFunction) and (FieldName = '*') then begin
                Field.SetRange(TableNo, RecordRef.Number);
                Field.SetFilter(Class, '%1|%2', Field.Class::Normal, Field.Class::FlowField);
                Field.SetFilter(Type, '<>%1&<>%2&<>%3&<>%4',
                    Field.Type::Blob,
                    Field.Type::Media,
                    Field.Type::MediaSet,
                    Field.Type::TableFilter);
                Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
                if Field.FindSet() then
                    repeat
                        FieldRef := RecordRef.Field(Field."No.");
                        AddFieldProperty(FieldRef, FieldRef.Name, JRecord, UseNames);
                    until Field.Next() = 0;
            end else begin
                JField.Get('Field', JToken);
                FieldID := JToken.AsValue().AsInteger();
                FieldRef := RecordRef.Field(FieldID);

                JField.Get('Name', JToken);
                FieldName := JToken.AsValue().AsText();
                if FieldName = '' then
                    FieldName := FieldRef.Name;

                AddFieldProperty(FieldRef, FieldName, JRecord, UseNames);
            end;
        end;

        exit(JRecord);
    end;

    local procedure AddFieldProperty(var FieldRef: FieldRef; FieldName: Text; JRecord: JsonObject; UseNames: Boolean)
    begin
        if FieldName = '' then
            FieldName := FieldRef.Name;

        FieldName := ConvertStr(FieldName, SpecialCharsTxt, PadStr('', StrLen(SpecialCharsTxt), '_'));
        AddJsonProperty(JRecord, FieldName, FieldRef, UseNames);
    end;

    local procedure AddJsonProperty(JRecord: JsonObject; Name: Text; FieldRef: FieldRef; UseNames: Boolean)
    var
        TextValue: Text;
        CodeValue: Code[2048];
        BigIntegerValue: BigInteger;
        BooleanValue: Boolean;
        DateValue: Date;
        DateTimeValue: DateTime;
        DecimalValue: Decimal;
        DurationValue: Duration;
        GuidValue: Guid;
        IntegerValue: Integer;
        OptionValue: Option;
        TimeValue: Time;
    begin
        if JRecord.Contains(Name) then
            exit;

        if FieldRef.Class = FieldRef.Class::FlowField then
            FieldRef.CalcField();

        case FieldRef.Type of
            FieldRef.Type::Text:
                begin
                    TextValue := FieldRef.Value;

                    JRecord.Add(Name, TextValue);
                end;
            FieldRef.Type::Code:
                begin
                    CodeValue := FieldRef.Value;
                    JRecord.Add(Name, CodeValue);
                end;
            FieldRef.Type::BigInteger:
                begin
                    BigIntegerValue := FieldRef.Value;
                    JRecord.Add(Name, BigIntegerValue);
                end;
            FieldRef.Type::Boolean:
                begin
                    BooleanValue := FieldRef.Value;
                    JRecord.Add(Name, BooleanValue);
                end;
            FieldRef.Type::Date:
                begin
                    DateValue := FieldRef.Value;
                    JRecord.Add(Name, DateValue);
                end;
            FieldRef.Type::DateTime:
                begin
                    DateTimeValue := FieldRef.Value;
                    JRecord.Add(Name, DateTimeValue);
                end;
            FieldRef.Type::Decimal:
                begin
                    DecimalValue := FieldRef.Value;
                    JRecord.Add(Name, DecimalValue);
                end;
            FieldRef.Type::Duration:
                begin
                    DurationValue := FieldRef.Value;
                    JRecord.Add(Name, DurationValue);
                end;
            FieldRef.Type::Guid:
                begin
                    GuidValue := FieldRef.Value;
                    JRecord.Add(Name, GuidValue);
                end;
            FieldRef.Type::Integer:
                begin
                    IntegerValue := FieldRef.Value;
                    JRecord.Add(Name, IntegerValue);
                end;
            FieldRef.Type::Option:
                if UseNames then
                    JRecord.Add(Name, Format(FieldRef.Value))
                else begin
                    OptionValue := FieldRef.Value;
                    JRecord.Add(Name, OptionValue);
                end;
            FieldRef.Type::Time:
                begin
                    TimeValue := FieldRef.Value;
                    JRecord.Add(Name, TimeValue);
                end;
            FieldRef.Type::Blob,
            FieldRef.Type::Media,
            FieldRef.Type::MediaSet,
            FieldRef.Type::RecordId,
            FieldRef.Type::TableFilter:
                JRecord.Add(Name, Format(FieldRef.Value, 0, 9));
            else
                JRecord.Add(Name, Format(FieldRef.Value, 0, 9));
        end;
    end;

    local procedure HasColumnFunctions(JASTNode: JsonObject): Boolean
    var
        JToken: JsonToken;
        JField: JsonObject;
        JFields: JsonArray;
    begin
        if not JASTNode.Get('Fields', JToken) then
            exit;

        JFields := JToken.AsArray();
        foreach JToken in JFields do begin
            JField := JToken.AsObject();
            if JField.Get('IsFunction', JToken) then
                if JToken.AsValue().AsBoolean() then
                    exit(true);
        end;
    end;

    local procedure QueryAsASTNode(QueryText: Text): JsonObject
    var
        JTokens: JsonArray;
        JASTNode: JsonObject;
        NewJASTNode: JsonObject;
    begin
        QueryText := DelChr(QueryText, '<>', ' ');
        if StrLen(QueryText) = 0 then
            Error(EmptyQueryErr);

        JTokens := InlineQueryTokenizer.Tokenize(QueryText);
        JASTNode := InlineQueryParser.Parse(JTokens);
        NewJASTNode := InlineQueryCompiler.Compile(JASTNode);

        exit(NewJASTNode);
    end;

    local procedure GetFunctionValue(var RecordRef: RecordRef; JASTNode: JsonObject; var ValueVariant: Variant)
    var
        JToken: JsonToken;
        JFields: JsonArray;
        JField: JsonObject;
    begin
        JASTNode.Get('Fields', JToken);
        JFields := JToken.AsArray();
        if JFields.Count() <> 1 then
            Error(SingleFunctionExpectedErr);

        JFields.Get(0, JToken);
        JField := JToken.AsObject();
        AggregateFieldValue(RecordRef, JASTNode, JField, ValueVariant);
    end;

    local procedure AggregateFieldValue(
        var RecordRef: RecordRef;
        JASTNode: JsonObject;
        JField: JsonObject;
        var ValueVariant: Variant)
    var
        FieldRef: FieldRef;
        JToken: JsonToken;
        IsFunction: Boolean;
        FieldID: Integer;
        NumberValue: Decimal;
        RecCount: Integer;
        FunctionType: Enum "Inline Query Function Type";
    begin
        JField.Get('IsFunction', JToken);
        IsFunction := JToken.AsValue().AsBoolean();

        if not IsFunction then
            Error(FunctionExpectedErr);

        JField.Get('Field', JToken);
        FieldID := JToken.AsValue().AsInteger();

        FieldRef := RecordRef.Field(FieldID);

        JField.Get('Function', JToken);
        FunctionType := "Inline Query Function Type".FromInteger(JToken.AsValue().AsInteger());

        case FunctionType of
            FunctionType::Count:
                ValueVariant := RecordRef.Count();
            FunctionType::Min:
                begin
                    SetOrderBy(JASTNode, RecordRef, FieldRef.Name);
                    if RecordRef.FindFirst() then
                        ValueVariant := FieldRef.Value;
                end;
            FunctionType::Max:
                begin
                    SetOrderBy(JASTNode, RecordRef, FieldRef.Name);
                    if RecordRef.FindLast() then
                        ValueVariant := FieldRef.Value;
                end;
            FunctionType::Avg:
                begin
                    FieldRef.CalcSum();
                    NumberValue := FieldRef.Value;
                    RecCount := RecordRef.Count();
                    if RecCount <> 0 then
                        ValueVariant := NumberValue / RecordRef.Count();
                end;
            FunctionType::Sum:
                begin
                    FieldRef.CalcSum();
                    ValueVariant := FieldRef.Value;
                end;
            FunctionType::First:
                if RecordRef.FindFirst() then begin
                    if FieldRef.Class = FieldClass::FlowField then
                        FieldRef.CalcField();

                    ValueVariant := FieldRef.Value;
                end;
            FunctionType::Last:
                if RecordRef.FindLast() then begin
                    if FieldRef.Class = FieldClass::FlowField then
                        FieldRef.CalcField();

                    ValueVariant := FieldRef.Value;
                end;
        end;
    end;

    local procedure PrepareRecRef(var RecordRef: RecordRef; JASTNode: JsonObject)
    var
        JFieldHeaders: JsonArray;
    begin
        PrepareRecRef(RecordRef, JASTNode, JFieldHeaders);
    end;

    local procedure PrepareRecRef(var RecordRef: RecordRef; JASTNode: JsonObject; JFieldHeaders: JsonArray)
    var
        JToken: JsonToken;
    begin
        JASTNode.Get('Table', JToken);
        OpenTable(RecordRef, JToken.AsObject());

        JASTNode.Get('Fields', JToken);
        AddLoadFields(RecordRef, JToken.AsArray(), JFieldHeaders);

        if JASTNode.Get('OrderBy', JToken) then
            ApplyOrderBy(RecordRef, JToken.AsArray());

        JASTNode.Get('Filters', JToken);
        ApplyFilters(RecordRef, JToken.AsArray());
    end;

    local procedure AddAllFieldHeaders(var RecordRef: RecordRef; JFieldHeaders: JsonArray)
    var
        Field: Record Field;
        FieldRef: FieldRef;
    begin
        Field.SetRange(TableNo, RecordRef.Number);
        Field.SetFilter(Class, '%1|%2', Field.Class::Normal, Field.Class::FlowField);
        Field.SetFilter(Type, '<>%1&<>%2&<>%3&<>%4',
            Field.Type::Blob,
            Field.Type::Media,
            Field.Type::MediaSet,
            Field.Type::TableFilter);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        if Field.FindSet() then
            repeat
                FieldRef := RecordRef.Field(Field."No.");
                JFieldHeaders.Add(GetFieldHeader(FieldRef, FieldRef.Name));
            until Field.Next() = 0;
    end;

    local procedure OpenTable(var RecordRef: RecordRef; JTable: JsonObject)
    var
        TableID: Integer;
        CompanyNameValue: Text;
        JToken: JsonToken;
    begin
        JTable.Get('Table', JToken);
        TableID := JToken.AsValue().AsInteger();

        if JTable.Get('Company', JToken) then
            CompanyNameValue := JToken.AsValue().AsText();

        if CompanyNameValue <> '' then
            RecordRef.Open(TableID, false, CompanyNameValue)
        else
            RecordRef.Open(TableID)
    end;

    local procedure AddLoadFields(var RecordRef: RecordRef; JFields: JsonArray; JFieldHeaders: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JFields do
            AddLoadField(RecordRef, JToken.AsObject(), JFieldHeaders);
    end;

    local procedure AddLoadField(var RecordRef: RecordRef; JField: JsonObject; JFieldHeaders: JsonArray)
    var
        FieldRef: FieldRef;
        JToken: JsonToken;
        FieldID: Integer;
        FieldName: Text;
        IsFunction: Boolean;
        FunctionType: Enum "Inline Query Function Type";
    begin
        JField.Get('Field', JToken);
        FieldName := JToken.AsValue().AsText();

        if JField.Get('IsFunction', JToken) then
            IsFunction := JToken.AsValue().AsBoolean();

        if (not IsFunction) and (FieldName = '*') then begin
            AddAllFieldHeaders(RecordRef, JFieldHeaders);
            exit;
        end;

        if IsFunction then begin
            JField.Get('Function', JToken);
            FunctionType := "Inline Query Function Type".FromInteger(JToken.AsValue().AsInteger());
            if FunctionType = FunctionType::Count then
                exit;
        end;

        JField.Get('Field', JToken);
        FieldID := JToken.AsValue().AsInteger();

        if not IsFunction then
            RecordRef.AddLoadFields(FieldID);
        FieldRef := RecordRef.Field(FieldID);

        JField.Get('Name', JToken);
        FieldName := JToken.AsValue().AsText();

        JFieldHeaders.Add(GetFieldHeader(FieldRef, FieldName));
    end;

    local procedure GetFieldHeader(var FieldRef: FieldRef; FieldName: Text): JsonObject
    var
        JFieldHeader: JsonObject;
    begin
        if FieldName = '' then begin
            JFieldHeader.Add('Caption', FieldRef.Caption);
            FieldName := FieldRef.Name;
        end else
            JFieldHeader.Add('Caption', FieldName);

        FieldName := ConvertStr(FieldName, SpecialCharsTxt, PadStr('', StrLen(SpecialCharsTxt), '_'));
        JFieldHeader.Add('Name', FieldName);

        exit(JFieldHeader);
    end;

    local procedure ApplyFilters(var RecordRef: RecordRef; JFilters: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JFilters do
            ApplyFilter(RecordRef, JToken.AsObject());
    end;

    local procedure ApplyFilter(var RecordRef: RecordRef; JFilter: JsonObject)
    var
        FieldRef: FieldRef;
        JToken: JsonToken;
        FieldID: Integer;
        FilterValue: Text;
        OperatorType: Enum "Inline Query Operator Type";
    begin
        JFilter.Get('Field', JToken);
        FieldID := JToken.AsValue().AsInteger();

        JFilter.Get('Operator', JToken);
        OperatorType := "Inline Query Operator Type".FromInteger(JToken.AsValue().AsInteger());

        JFilter.Get('Filter', JToken);
        FilterValue := JToken.AsValue().AsText();

        FieldRef := RecordRef.Field(FieldID);
        case OperatorType of
            OperatorType::"Equal To",
            OperatorType::Like:
                FieldRef.SetFilter(FilterValue);
            OperatorType::"Not Equal To":
                FieldRef.SetFilter('<>' + FilterValue);
            OperatorType::"Less Than":
                FieldRef.SetFilter('<' + FilterValue);
            OperatorType::"Less Than or Equal To":
                FieldRef.SetFilter('<=' + FilterValue);
            OperatorType::"Greater Than":
                FieldRef.SetFilter('>' + FilterValue);
            OperatorType::"Greater Than or Equal To":
                FieldRef.SetFilter('>=' + FilterValue);
        end;
    end;

    local procedure ApplyOrderBy(var RecordRef: RecordRef; JFields: JsonArray)
    var
        FieldRef: FieldRef;
        JToken: JsonToken;
        FieldID: Integer;
        TableKey: Text;
    begin
        if JFields.Count() = 0 then
            exit;

        foreach JToken in JFields do begin
            FieldID := JToken.AsValue().AsInteger();
            FieldRef := RecordRef.Field(FieldID);
            if TableKey = '' then
                TableKey := FieldRef.Name
            else
                TableKey += ',' + FieldRef.Name;
        end;

        RecordRef.SetView(StrSubstNo(SortingLbl, TableKey));
    end;

    local procedure SetOrderBy(JASTNode: JsonObject; var RecordRef: RecordRef; FieldName: Text)
    var
        JToken: JsonToken;
    begin
        if not JASTNode.Get('OrderBy', JToken) then
            exit;

        if JToken.AsArray().Count() > 0 then
            exit;

        RecordRef.FilterGroup := 2;
        RecordRef.SetView(StrSubstNo(SortingLbl, FieldName));
        RecordRef.FilterGroup := 0;
    end;
}