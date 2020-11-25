codeunit 50101 "Inline Query Impl"
{
    Access = Internal;

    var
        InlineQueryJsonHelper: Codeunit "Inline Query Json Helper";
        InlineQueryTokenizer: Codeunit "Inline Query Tokenizer";
        InlineQueryParser: Codeunit "Inline Query Parser";
        InlineQueryCompiler: Codeunit "Inline Query Compiler";
        EmptyQueryErr: Label 'Query should not be empty.';
        FunctionExpectedErr: Label 'Function expected.';
        SingleFunctionExpectedErr: Label 'A single function expected.';
        SortingTxt: Label 'SORTING(%1)', Locked = true, Comment = '%1 = Field';
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
        JQueryNode: JsonObject;
    begin
        JQueryNode := Compile(QueryText);
        PrepareRecRef(RecordRef, JQueryNode);

        GetFunctionValue(RecordRef, JQueryNode, ValueVariant);
    end;

    procedure AsRecord(QueryText: Text; var RecordRef: RecordRef)
    var
        JQueryNode: JsonObject;
    begin
        JQueryNode := Compile(QueryText);
        PrepareRecRef(RecordRef, JQueryNode);
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
        JQueryNode: JsonObject;
        JFields: JsonArray;
        JTable: JsonObject;
        JFilters: JsonArray;
        JOrderByFields: JsonArray;
        Top: Integer;
    begin
        JQueryNode := Compile(QueryText);
        InlineQueryJsonHelper.ReadSelectQuery(JQueryNode, Top, JFields, JTable, JFilters, JOrderByFields);

        if HasColumnFunctions(JFields) then
            exit(FunctionValuesAsJson(JQueryNode, JOrderByFields, JFieldHeaders));

        PrepareRecRef(RecordRef, JQueryNode, JFieldHeaders);
        if JFields.Count() = 0 then
            exit;

        exit(Records2Json(RecordRef, JFields, Top, UseNames))
    end;

    local procedure FunctionValuesAsJson(JQueryNode: JsonObject; JOrderByFields: JsonArray; JFieldHeaders: JsonArray): JsonArray
    var
        RecordRef: RecordRef;
        JFieldHeaders2: JsonArray;
        JToken: JsonToken;
        JFields: JsonArray;
        JTable: JsonObject;
        JFilters: JsonArray;
        JRecords: JsonArray;
        JRecord: JsonObject;
        JField: JsonObject;
        Top: Integer;
    begin
        PrepareRecRef(RecordRef, JQueryNode, JFieldHeaders2);

        InlineQueryJsonHelper.ReadSelectQuery(JQueryNode, Top, JFields, JTable, JFilters, JOrderByFields);
        foreach JToken in JFields do begin
            JField := JToken.AsObject();
            FunctionValueAsJson(RecordRef, JOrderByFields, JRecord, JField, JFieldHeaders);
        end;

        JRecords.Add(JRecord);
        exit(JRecords);
    end;

    local procedure FunctionValueAsJson(
        RecordRef: RecordRef;
        JOrderByFields: JsonArray;
        JRecord: JsonObject;
        JField: JsonObject;
        JFieldHeaders: JsonArray)
    var
        FieldRef: FieldRef;
        ValueVariant: Variant;
        IsFunction: Boolean;
        FieldID: Integer;
        AliasName: Text;
        FieldName: Text;
        FunctionType: Enum "Inline Query Function Type";
    begin
        AggregateFieldValue(RecordRef, JOrderByFields, JField, ValueVariant);
        InlineQueryJsonHelper.ReadSelectField(JField, FieldID, IsFunction, FunctionType, AliasName);

        if not IsFunction then
            Error(AggregateExprExpectedErr, AliasName);

        if AliasName = '' then
            if FieldID <> 0 then begin
                FieldRef := RecordRef.Field(FieldID);
                AliasName := Format(FunctionType) + ' of ' + FieldRef.Name;
            end else
                AliasName := Format(FunctionType);

        FieldName := ConvertStr(AliasName, SpecialCharsTxt, PadStr('', StrLen(SpecialCharsTxt), '_'));
        JFieldHeaders.Add(InlineQueryJsonHelper.AsGridHeader(AliasName, FieldName));
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
        AllFields: Boolean;
        AliasName: Text;
        FunctionType: Enum "Inline Query Function Type";
    begin
        foreach JToken in JFields do begin
            JField := JToken.AsObject();
            AllFields := InlineQueryJsonHelper.ReadSelectAllFields(JField);

            if AllFields then begin
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
                InlineQueryJsonHelper.ReadSelectField(JField, FieldID, IsFunction, FunctionType, AliasName);
                FieldRef := RecordRef.Field(FieldID);

                if AliasName = '' then
                    AliasName := FieldRef.Name;

                AddFieldProperty(FieldRef, AliasName, JRecord, UseNames);
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

    local procedure AddJsonProperty(JRecord: JsonObject; FieldName: Text; FieldRef: FieldRef; UseNames: Boolean)
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
        if JRecord.Contains(FieldName) then
            exit;

        if FieldRef.Class = FieldRef.Class::FlowField then
            FieldRef.CalcField();

        case FieldRef.Type of
            FieldRef.Type::Text:
                begin
                    TextValue := FieldRef.Value;

                    JRecord.Add(FieldName, TextValue);
                end;
            FieldRef.Type::Code:
                begin
                    CodeValue := FieldRef.Value;
                    JRecord.Add(FieldName, CodeValue);
                end;
            FieldRef.Type::BigInteger:
                begin
                    BigIntegerValue := FieldRef.Value;
                    JRecord.Add(FieldName, BigIntegerValue);
                end;
            FieldRef.Type::Boolean:
                begin
                    BooleanValue := FieldRef.Value;
                    JRecord.Add(FieldName, BooleanValue);
                end;
            FieldRef.Type::Date:
                begin
                    DateValue := FieldRef.Value;
                    JRecord.Add(FieldName, DateValue);
                end;
            FieldRef.Type::DateTime:
                begin
                    DateTimeValue := FieldRef.Value;
                    JRecord.Add(FieldName, DateTimeValue);
                end;
            FieldRef.Type::Decimal:
                begin
                    DecimalValue := FieldRef.Value;
                    JRecord.Add(FieldName, DecimalValue);
                end;
            FieldRef.Type::Duration:
                begin
                    DurationValue := FieldRef.Value;
                    JRecord.Add(FieldName, DurationValue);
                end;
            FieldRef.Type::Guid:
                begin
                    GuidValue := FieldRef.Value;
                    JRecord.Add(FieldName, GuidValue);
                end;
            FieldRef.Type::Integer:
                begin
                    IntegerValue := FieldRef.Value;
                    JRecord.Add(FieldName, IntegerValue);
                end;
            FieldRef.Type::Option:
                if UseNames then
                    JRecord.Add(FieldName, Format(FieldRef.Value))
                else begin
                    OptionValue := FieldRef.Value;
                    JRecord.Add(FieldName, OptionValue);
                end;
            FieldRef.Type::Time:
                begin
                    TimeValue := FieldRef.Value;
                    JRecord.Add(FieldName, TimeValue);
                end;
            FieldRef.Type::Blob,
            FieldRef.Type::Media,
            FieldRef.Type::MediaSet,
            FieldRef.Type::RecordId,
            FieldRef.Type::TableFilter:
                JRecord.Add(FieldName, Format(FieldRef.Value, 0, 9));
            else
                JRecord.Add(FieldName, Format(FieldRef.Value, 0, 9));
        end;
    end;

    local procedure HasColumnFunctions(JFields: JsonArray): Boolean
    var
        JToken: JsonToken;
        JField: JsonObject;
    begin
        if JFields.Count() = 0 then
            exit;

        foreach JToken in JFields do begin
            JField := JToken.AsObject();
            if InlineQueryJsonHelper.ReadSelectFieldIsFunction(JField) then
                exit(true);
        end;
    end;

    local procedure Compile(QueryText: Text): JsonObject
    var
        JTokens: JsonArray;
        JQueryNode: JsonObject;
        JNewQueryNode: JsonObject;
    begin
        QueryText := DelChr(QueryText, '<>', ' ');
        if StrLen(QueryText) = 0 then
            Error(EmptyQueryErr);

        JTokens := InlineQueryTokenizer.Tokenize(QueryText);
        JQueryNode := InlineQueryParser.Parse(QueryText, JTokens);
        JNewQueryNode := InlineQueryCompiler.Compile(JQueryNode);

        exit(JNewQueryNode);
    end;

    local procedure GetFunctionValue(var RecordRef: RecordRef; JQueryNode: JsonObject; var ValueVariant: Variant)
    var
        Top: Integer;
        JToken: JsonToken;
        JFields: JsonArray;
        JTable: JsonObject;
        JFilters: JsonArray;
        JOrderByFields: JsonArray;
        JField: JsonObject;
    begin
        InlineQueryJsonHelper.ReadSelectQuery(JQueryNode, Top, JFields, JTable, JFilters, JOrderByFields);

        if JFields.Count() <> 1 then
            Error(SingleFunctionExpectedErr);

        JFields.Get(0, JToken);
        JField := JToken.AsObject();
        AggregateFieldValue(RecordRef, JOrderByFields, JField, ValueVariant);
    end;

    local procedure AggregateFieldValue(
        var RecordRef: RecordRef;
        JOrderByFields: JsonArray;
        JField: JsonObject;
        var ValueVariant: Variant)
    var
        FieldRef: FieldRef;
        IsFunction: Boolean;
        FieldID: Integer;
        NumberValue: Decimal;
        RecCount: Integer;
        AliasName: Text;
        FunctionType: Enum "Inline Query Function Type";
    begin
        InlineQueryJsonHelper.ReadSelectField(JField, FieldID, IsFunction, FunctionType, AliasName);

        if not IsFunction then
            Error(FunctionExpectedErr);

        FieldRef := RecordRef.Field(FieldID);

        case FunctionType of
            FunctionType::Count:
                ValueVariant := RecordRef.Count();
            FunctionType::Min:
                begin
                    if JOrderByFields.Count() = 0 then
                        SetOrderBy(RecordRef, FieldRef.Name);

                    if RecordRef.FindFirst() then
                        ValueVariant := FieldRef.Value;
                end;
            FunctionType::Max:
                begin
                    if JOrderByFields.Count() = 0 then
                        SetOrderBy(RecordRef, FieldRef.Name);

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

    local procedure PrepareRecRef(var RecordRef: RecordRef; JQueryNode: JsonObject)
    var
        JFieldHeaders: JsonArray;
    begin
        PrepareRecRef(RecordRef, JQueryNode, JFieldHeaders);
    end;

    local procedure PrepareRecRef(var RecordRef: RecordRef; JQueryNode: JsonObject; JFieldHeaders: JsonArray)
    var
        Top: Integer;
        JFields: JsonArray;
        JTable: JsonObject;
        JFilters: JsonArray;
        JOrderByFields: JsonArray;
    begin
        InlineQueryJsonHelper.ReadSelectQuery(JQueryNode, Top, JFields, JTable, JFilters, JOrderByFields);
        OpenTable(RecordRef, JTable);

        AddLoadFields(RecordRef, JFields, JFieldHeaders);
        ApplyOrderBy(RecordRef, JOrderByFields);
        ApplyFilters(RecordRef, JFilters);
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
        CompanyName: Text;
    begin
        InlineQueryJsonHelper.ReadSourceTable(JTable, TableID, CompanyName);

        if CompanyName <> '' then
            RecordRef.Open(TableID, false, CompanyName)
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
        FieldID: Integer;
        FieldName: Text;
        IsFunction: Boolean;
        AllFields: Boolean;
        FunctionType: Enum "Inline Query Function Type";
    begin
        AllFields := InlineQueryJsonHelper.ReadSelectAllFields(JField);
        if AllFields then begin
            AddAllFieldHeaders(RecordRef, JFieldHeaders);
            exit;
        end;

        InlineQueryJsonHelper.ReadSelectField(JField, FieldID, IsFunction, FunctionType, FieldName);
        if FunctionType = FunctionType::Count then
            exit;

        if not IsFunction then
            RecordRef.AddLoadFields(FieldID);

        FieldRef := RecordRef.Field(FieldID);
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
        FieldID: Integer;
        FilterValue: Text;
        OperatorType: Enum "Inline Query Operator Type";
    begin
        InlineQueryJsonHelper.ReadFilter(JFilter, FieldID, OperatorType, FilterValue);

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

        RecordRef.SetView(StrSubstNo(SortingTxt, TableKey));
    end;

    local procedure SetOrderBy(var RecordRef: RecordRef; FieldName: Text)
    begin
        RecordRef.FilterGroup := 2;
        RecordRef.SetView(StrSubstNo(SortingTxt, FieldName));
        RecordRef.FilterGroup := 0;
    end;
}