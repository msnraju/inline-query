codeunit 50103 "Inline Query Compiler"
{
    Access = Internal;

    var
        ObjectNotFoundErr: Label '''%1'' %2 not found.', Comment = '%1 = Object Name, %2 = Object Type';
        InvalidOperatorErr: Label 'Syntax error, Invalid operator %1.', Comment = '%1 = Operator';
        InvalidFunctionErr: Label 'Syntax error, Invalid function ''%1''.', Comment = '%1 = Function';

    procedure Compile(JASTNode: JsonObject): JsonObject
    var
        TableID: Integer;
        JToken: JsonToken;
        JTable: JsonObject;
        JFields: JsonArray;
        JFilters: JsonArray;
        JOrderByFields: JsonArray;
        NewJASTNode: JsonObject;
        Top: Integer;
    begin
        if JASTNode.Get('Table', JToken) then
            JTable := CompileTable(JToken.AsObject(), TableID);

        if JASTNode.Get('Top', JToken) then
            Top := JToken.AsValue().AsInteger();

        if JASTNode.Get('Fields', JToken) then
            JFields := CompileFields(JToken.AsArray(), TableID);

        if JASTNode.Get('Filters', JToken) then
            JFilters := CompileFilters(JToken.AsArray(), TableID);

        if JASTNode.Get('OrderBy', JToken) then
            JOrderByFields := CompileOrderByFields(JToken.AsArray(), TableID);

        NewJASTNode.Add('Top', Top);
        NewJASTNode.Add('Fields', JFields);
        NewJASTNode.Add('Table', JTable);
        NewJASTNode.Add('Filters', JFilters);
        NewJASTNode.Add('OrderBy', JOrderByFields);

        exit(NewJASTNode);
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
        OperatorType: Enum "Inline Query Operator Type";
        FieldID: Integer;
        FieldName: Text;
        Operator: Text;
        FilterValue: Text;
        JToken: JsonToken;
        NewJFilter: JsonObject;
    begin
        if JFilter.Get('Field', JToken) then
            FieldName := JToken.AsValue().AsText();

        FieldID := GetFieldID(FieldName, TableID);

        if JFilter.Get('Operator', JToken) then
            Operator := JToken.AsValue().AsText();

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
                Error(InvalidOperatorErr, Operator);
        end;

        if JFilter.Get('Filter', JToken) then
            FilterValue := JToken.AsValue().AsText();

        if OperatorType <> OperatorType::Like then begin
            RecordRef.Open(TableID);
            FieldRef := RecordRef.Field(FieldID);
            FieldRef.SetFilter(FilterValue);
            FilterValue := FieldRef.GetFilter();
            RecordRef.Close();
        end;

        NewJFilter.Add('Field', FieldID);
        NewJFilter.Add('Operator', OperatorType.AsInteger());
        NewJFilter.Add('Filter', FilterValue);
        exit(NewJFilter);
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
        JToken: JsonToken;
        IsFunction: Boolean;
        FunctionName: Text;
        FieldID: Integer;
        FieldName: Text;
        FunctionType: Enum "Inline Query Function Type";
        NewJFieldNode: JsonObject;
    begin
        JField.Get('Field', JToken);
        FieldName := JToken.AsValue().AsText();

        if JField.Get('IsFunction', JToken) then
            IsFunction := JToken.AsValue().AsBoolean();

        if (not IsFunction) and (FieldName = '*') then begin
            NewJFieldNode.Add('Field', '*');
            exit(NewJFieldNode);
        end;

        if IsFunction then begin
            if JField.Get('Function', JToken) then
                FunctionName := JToken.AsValue().AsText();

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
                    Error(InvalidFunctionErr, FunctionName);
            end;
        end;

        if FunctionType <> FunctionType::Count then
            FieldID := GetFieldID(FieldName, TableID);

        NewJFieldNode.Add('IsFunction', IsFunction);
        if IsFunction then
            NewJFieldNode.Add('Function', FunctionType.AsInteger());

        NewJFieldNode.Add('Field', FieldID);

        JField.Get('Name', JToken);
        NewJFieldNode.Add('Name', JToken.AsValue().AsText());

        exit(NewJFieldNode);
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
        CompanyNameValue: Text;
        JToken: JsonToken;
        NewTable: JsonObject;
    begin
        if JTable.Get('Table', JToken) then
            TableName := JToken.AsValue().AsText();

        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetFilter("Object Name", '%1', '@' + TableName);
        if not AllObj.FindFirst() then
            Error(ObjectNotFoundErr, TableName, 'table');

        TableID := AllObj."Object ID";

        if JTable.Get('Company', JToken) then begin
            CompanyNameValue := JToken.AsValue().AsText();

            if CompanyNameValue <> '' then begin
                Company.SetFilter(Name, '%1', '@' + CompanyNameValue);
                if not Company.FindFirst() then
                    Error(ObjectNotFoundErr, CompanyNameValue, 'company');

                CompanyNameValue := Company.Name;
            end;
        end;

        NewTable.Add('Table', TableID);
        NewTable.Add('Company', CompanyNameValue);
        exit(NewTable);
    end;

    local procedure GetFieldID(FieldName: Text; TableID: Integer): Integer
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableID);
        Field.SetFilter(FieldName, '%1', '@' + FieldName);
        if not Field.FindFirst() then
            Error(ObjectNotFoundErr, FieldName, 'field');

        exit(Field."No.");
    end;
}