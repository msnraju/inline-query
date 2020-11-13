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
        SortingLbl: Label 'SORTING(%1)', Comment = '%1 = Field';
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
                    RecordRef.SetView(StrSubstNo(SortingLbl, FieldRef.Name));
                    if RecordRef.FindFirst() then
                        ValueVariant := FieldRef.Value;
                end;
            FunctionType::Max:
                begin
                    RecordRef.SetView(StrSubstNo(SortingLbl, FieldRef.Name));
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

    local procedure ApplyFilters(var RecordRef: RecordRef; JFilters: JsonArray)
    var
        JToken: JsonToken;
    begin
        RecordRef.FilterGroup := 2;
        foreach JToken in JFilters do
            ApplyFilter(RecordRef, JToken.AsObject());

        RecordRef.FilterGroup := 0;
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
}