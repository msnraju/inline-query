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
        AggregateFunctionsErr: Label 'Cannot use aggregate function in this method.';
        SortingLbl: Label 'SORTING(%1)', Locked = true, Comment = '%1 = Field';

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
        RecordRef: RecordRef;
        JASTNode: JsonObject;
        JToken: JsonToken;
        Top: Integer;
    begin
        JASTNode := QueryAsASTNode(QueryText);
        if HasColumnFunctions(JASTNode) then
            Error(AggregateFunctionsErr);

        PrepareRecRef(RecordRef, JASTNode);

        if JASTNode.Get('Top', JToken) then
            Top := JToken.AsValue().AsInteger();

        if not JASTNode.Get('Fields', JToken) then
            exit;

        exit(Records2Json(RecordRef, JToken.AsArray(), Top))
    end;

    local procedure Records2Json(var RecordRef: RecordRef; JFields: JsonArray; Top: Integer): JsonArray
    var
        JRecords: JsonArray;
        Counter: Integer;
    begin
        if RecordRef.FindSet() then
            repeat
                Counter += 1;
                JRecords.Add(Record2Json(RecordRef, JFields));

                if (Top <> 0) and (Counter >= Top) then
                    break;
            until RecordRef.Next() = 0;

        exit(JRecords);
    end;

    local procedure Record2Json(var RecordRef: RecordRef; JFields: JsonArray): JsonObject
    var
        FieldRef: FieldRef;
        JRecord: JsonObject;
        JToken: JsonToken;
        JField: JsonObject;
        FieldID: Integer;
        Name: Text;
    begin
        foreach JToken in JFields do begin
            JField := JToken.AsObject();

            JField.Get('Field', JToken);
            FieldID := JToken.AsValue().AsInteger();
            FieldRef := RecordRef.Field(FieldID);

            JField.Get('Name', JToken);
            Name := JToken.AsValue().AsText();

            if Name = '' then
                Name := FieldRef.Name;

            AddJsonProperty(JRecord, Name, FieldRef);
        end;

        exit(JRecord);
    end;

    local procedure AddJsonProperty(JRecord: JsonObject; Name: Text; FieldRef: FieldRef)
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
                begin
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
        FieldRef: FieldRef;
        JToken: JsonToken;
        JFields: JsonArray;
        JField: JsonObject;
        IsFunction: Boolean;
        FieldID: Integer;
        RecCount: Integer;
        NumberValue: Decimal;
        FunctionType: Enum "Inline Query Function Type";
    begin
        JASTNode.Get('Fields', JToken);
        JFields := JToken.AsArray();
        if JFields.Count() <> 1 then
            Error(SingleFunctionExpectedErr);

        JFields.Get(0, JToken);
        JField := JToken.AsObject();

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
        JToken: JsonToken;
    begin
        JASTNode.Get('Table', JToken);
        OpenTable(RecordRef, JToken.AsObject());

        JASTNode.Get('Fields', JToken);
        AddLoadFields(RecordRef, JToken.AsArray());

        if JASTNode.Get('OrderBy', JToken) then
            ApplyOrderBy(RecordRef, JToken.AsArray());

        JASTNode.Get('Filters', JToken);
        ApplyFilters(RecordRef, JToken.AsArray());
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

    local procedure AddLoadFields(var RecordRef: RecordRef; JFields: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JFields do
            AddLoadField(RecordRef, JToken.AsObject());
    end;

    local procedure AddLoadField(var RecordRef: RecordRef; JField: JsonObject)
    var
        JToken: JsonToken;
        FieldID: Integer;
        IsFunction: Boolean;
        FunctionType: Enum "Inline Query Function Type";
    begin
        JField.Get('IsFunction', JToken);
        IsFunction := JToken.AsValue().AsBoolean();

        if IsFunction then begin
            JField.Get('Function', JToken);
            FunctionType := "Inline Query Function Type".FromInteger(JToken.AsValue().AsInteger());
            if FunctionType = FunctionType::Count then
                exit;
        end;

        JField.Get('Field', JToken);
        FieldID := JToken.AsValue().AsInteger();
        RecordRef.AddLoadFields(FieldID);
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