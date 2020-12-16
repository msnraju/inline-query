codeunit 50103 "Inline Query Compiler"
{
    Access = Internal;

    var
        InlineQueryJsonHelper: Codeunit "Inline Query Json Helper";
        InvalidFieldNameErr: Label 'Invalid field name ''%1''.', Comment = '%1 = Field Name';
        InvalidTableNameErr: Label 'Invalid table name ''%1''.', Comment = '%1 = Table Name';
        InvalidCompanyNameErr: Label 'Invalid company name ''%1''.', Comment = '%1 = Table Name';
        IncorrectSyntaxErr: Label 'Incorrect syntax near ''%1''.', Comment = '%1 = Token Value';
        NotImplementedErr: Label 'Query type ''%1'' not implemented.', Comment = '%1 = Query Type';

    procedure Compile(JQueryNode: JsonObject): JsonObject
    var
        QueryType: Enum "Inline Query Type";
    begin
        QueryType := InlineQueryJsonHelper.GetQueryType(JQueryNode);
        case QueryType of
            QueryType::Select:
                exit(CompileSelectQuery(JQueryNode));
            QueryType::Delete:
                exit(CompileDeleteQuery(JQueryNode));
            else
                Error(NotImplementedErr, QueryType);
        end;
    end;

    local procedure CompileSelectQuery(JQueryNode: JsonObject): JsonObject
    var
        Top: Integer;
        JParseTable: JsonObject;
        JParseFields: JsonArray;
        JParseFilters: JsonArray;
        JParseOrderByFields: JsonArray;
        JTable: JsonObject;
        JFields: JsonArray;
        JFilters: JsonArray;
        JOrderByFields: JsonArray;
        TableID: Integer;
    begin
        InlineQueryJsonHelper.ReadSelectQuery(JQueryNode, Top, JParseFields, JParseTable, JParseFilters, JParseOrderByFields);

        JTable := CompileTable(JParseTable, TableID);
        JFields := CompileFields(JParseFields, TableID);
        JFilters := CompileFilters(JParseFilters, TableID);
        JOrderByFields := CompileOrderByFields(JParseOrderByFields, TableID);

        exit(InlineQueryJsonHelper.AsSelectQuery(Top, JFields, JTable, JFilters, JOrderByFields));
    end;

    local procedure CompileDeleteQuery(JQueryNode: JsonObject): JsonObject
    var
        Top: Integer;
        JParseTable: JsonObject;
        JParseFilters: JsonArray;
        JTable: JsonObject;
        JFilters: JsonArray;
        TableID: Integer;
    begin
        InlineQueryJsonHelper.ReadDeleteQuery(JQueryNode, Top, JParseTable, JParseFilters);

        JTable := CompileTable(JParseTable, TableID);
        JFilters := CompileFilters(JParseFilters, TableID);

        exit(InlineQueryJsonHelper.AsDeleteQuery(Top, JTable, JFilters));
    end;

    local procedure CompileFilters(JFilters: JsonArray; TableID: Integer): JsonArray
    var
        JToken: JsonToken;
        NewJFilters: JsonArray;
    begin
        foreach JToken in JFilters do
            NewJFilters.Add(CompileFilter(JToken.AsObject(), TableID));

        exit(NewJFilters);
    end;

    local procedure CompileFilter(JFilter: JsonObject; TableID: Integer): JsonObject
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldName: Text;
        Operator: Text;
        FilterValue: Text;
        FieldID: Integer;
        OperatorType: Enum "Inline Query Operator Type";
    begin
        InlineQueryJsonHelper.ReadFilter(JFilter, FieldName, Operator, FilterValue);
        FieldID := GetFieldID(FieldName, TableID);

        case UpperCase(Operator) of
            '=':
                OperatorType := OperatorType::"Equal To";
            '<>':
                OperatorType := OperatorType::"Not Equal To";
            '>':
                OperatorType := OperatorType::"Greater Than";
            '>=':
                OperatorType := OperatorType::"Greater Than or Equal To";
            '<':
                OperatorType := OperatorType::"Less Than";
            '<=':
                OperatorType := OperatorType::"Less Than or Equal To";
            'LIKE':
                OperatorType := OperatorType::Like;
            else
                Error(IncorrectSyntaxErr, Operator);
        end;

        if OperatorType <> OperatorType::Like then begin
            RecordRef.Open(TableID);
            FieldRef := RecordRef.Field(FieldID);
            FieldRef.SetFilter(FilterValue);
            FilterValue := FieldRef.GetFilter();
            RecordRef.Close();
        end;

        exit(InlineQueryJsonHelper.AsFilter(FieldID, OperatorType, FilterValue));
    end;

    local procedure CompileFields(JFields: JsonArray; TableID: Integer): JsonArray
    var
        JToken: JsonToken;
        JField: JsonObject;
        NewJFields: JsonArray;
    begin
        foreach JToken in JFields do begin
            JField := CompileField(JToken.AsObject(), TableID);
            NewJFields.Add(JField);
        end;

        exit(NewJFields);
    end;

    local procedure CompileField(JField: JsonObject; TableID: Integer): JsonObject
    var
        AllFields: Boolean;
        IsFunction: Boolean;
        FunctionName: Text;
        FieldID: Integer;
        FieldName: Text;
        AliasName: Text;
        FunctionType: Enum "Inline Query Function Type";
    begin
        AllFields := InlineQueryJsonHelper.ReadSelectAllFields(JField);
        if AllFields then
            exit(InlineQueryJsonHelper.AsSelectAllFields());

        InlineQueryJsonHelper.ReadSelectField(JField, FieldName, IsFunction, FunctionName, AliasName);

        if IsFunction then
            case UpperCase(FunctionName) of
                'COUNT':
                    FunctionType := FunctionType::Count;
                'MIN':
                    FunctionType := FunctionType::Min;
                'MAX':
                    FunctionType := FunctionType::Max;
                'AVG':
                    FunctionType := FunctionType::Avg;
                'SUM':
                    FunctionType := FunctionType::Sum;
                'FIRST':
                    FunctionType := FunctionType::First;
                'LAST':
                    FunctionType := FunctionType::Last;
                else
                    Error(IncorrectSyntaxErr, FunctionName);
            end;

        if FunctionType <> FunctionType::Count then
            FieldID := GetFieldID(FieldName, TableID);

        exit(InlineQueryJsonHelper.AsSelectField(FieldID, IsFunction, FunctionType, AliasName));
    end;

    local procedure CompileOrderByFields(JFields: JsonArray; TableID: Integer): JsonArray
    var
        JToken: JsonToken;
        FieldID: Integer;
        NewJFields: JsonArray;
    begin
        foreach JToken in JFields do begin
            FieldID := GetFieldID(JToken.AsValue().AsText(), TableID);
            NewJFields.Add(FieldID);
        end;

        exit(NewJFields);
    end;

    local procedure CompileTable(JTable: JsonObject; var TableID: Integer): JsonObject
    var
        AllObj: Record AllObj;
        Company: Record Company;
        TableName: Text;
        CompanyName: Text;
    begin
        InlineQueryJsonHelper.ReadSourceTable(JTable, TableName, CompanyName);

        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetFilter("Object Name", '%1', '@' + TableName);
        if not AllObj.FindFirst() then
            Error(InvalidTableNameErr, TableName);

        TableID := AllObj."Object ID";

        if CompanyName <> '' then begin
            Company.SetFilter(Name, '%1', '@' + CompanyName);
            if not Company.FindFirst() then
                Error(InvalidCompanyNameErr, CompanyName);

            CompanyName := Company.Name;
        end;

        exit(InlineQueryJsonHelper.AsSourceTable(TableID, CompanyName));
    end;

    local procedure GetFieldID(FieldName: Text; TableID: Integer): Integer
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableID);
        Field.SetFilter(FieldName, '%1', '@' + FieldName);
        if not Field.FindFirst() then
            Error(InvalidFieldNameErr, FieldName);

        exit(Field."No.");
    end;
}