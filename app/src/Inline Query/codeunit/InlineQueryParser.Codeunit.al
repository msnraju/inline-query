codeunit 50102 "Inline Query Parser"
{
    Access = Internal;

    var
        SyntaxErrorErr: Label 'Syntax error, %1 expected.', Comment = '%1 = Token';
        InvalidOperatorErr: Label 'Syntax error, Invalid operator ''%1''.', Comment = '%1 = Operator';

    procedure Parse(JTokens: JsonArray): JsonObject
    var
        Pos: Integer;
        JTable: JsonObject;
        JFields: JsonArray;
        JFilters: JsonArray;
        JASTNode: JsonObject;
    begin
        if JTokens.Count() = 0 then
            exit;

        Pos := 0;

        ParseQueryType(JTokens, Pos);

        JFields := ParseFields(JTokens, Pos);
        JTable := ParseTable(JTokens, Pos);
        JFilters := ParseFilters(JTokens, Pos);

        JASTNode.Add('Fields', JFields);
        JASTNode.Add('Table', JTable);
        JASTNode.Add('Filters', JFilters);

        exit(JASTNode);
    end;

    local procedure ParseQueryType(JTokens: JsonArray; var Pos: Integer)
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
    begin
        if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
            Error(SyntaxErrorErr, 'SELECT');

        if (UpperCase(TokenValue) <> 'SELECT') then
            Error(SyntaxErrorErr, 'SELECT');
    end;

    local procedure ParseFilters(JTokens: JsonArray; var Pos: Integer): JsonArray
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
        FieldName: Text;
        Operator: Text;
        FilterValue: Text;
        JFilters: JsonArray;
    begin
        if not PeekToken(JTokens, Pos, TokenValue, TokenType) then
            exit;

        if UpperCase(TokenValue) <> 'WHERE' then
            Error(SyntaxErrorErr, 'WHERE');

        Pos += 1;
        TokenValue := '';

        while (TokenValue = '') or (UpperCase(TokenValue) = 'AND') or (UpperCase(TokenValue) = 'OR') do begin
            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'Field');

            FieldName := TokenValue;

            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'Operator');

            case TokenType of
                TokenType::"Equal To",
                TokenType::"Not Equal To",
                TokenType::"Less Than",
                TokenType::"Less Than or Equal To",
                TokenType::"Greater Than",
                TokenType::"Greater Than or Equal To":
                    Operator := TokenValue;
                else
                    Operator := TokenValue;
                    if UpperCase(TokenValue) <> 'LIKE' then
                        Error(InvalidOperatorErr, Operator);
            end;

            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'Filter Value');

            FilterValue := TokenValue;

            JFilters.Add(GetFilterNode(FieldName, Operator, FilterValue));

            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Break;
        end;

        exit(JFilters);
    end;

    local procedure ParseTable(JTokens: JsonArray; var Pos: Integer): JsonObject
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
        CompanyNameValue: Text;
        TableName: Text;
    begin
        if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
            Error(SyntaxErrorErr, 'Table');

        TableName := TokenValue;

        if PeekToken(JTokens, Pos, TokenValue, TokenType) then
            if TokenType = TokenType::Period then begin
                Pos += 1;
                if ReadToken(JTokens, Pos, TokenValue, TokenType) then begin
                    CompanyNameValue := TableName;
                    TableName := TokenValue;
                end;
            end;


        exit(GetTableNode(TableName, CompanyNameValue));
    end;

    local procedure ParseFields(JTokens: JsonArray; var Pos: Integer): JsonArray
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
        FieldName: Text;
        FunctionName: Text;
        JFields: JsonArray;
    begin
        while UpperCase(TokenValue) <> 'FROM' do begin
            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'Field');

            FieldName := TokenValue;

            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'FROM');

            case TokenType of
                TokenType::"Opening Parenthesis":
                    begin
                        FunctionName := FieldName;

                        if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                            Error(SyntaxErrorErr, 'Field');

                        FieldName := TokenValue;
                        if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                            Error(SyntaxErrorErr, ')');

                        if TokenType <> TokenType::"Closing Parenthesis" then
                            Error(SyntaxErrorErr, ')');

                        if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                            Error(SyntaxErrorErr, 'FROM');

                        JFields.Add(GetFieldNode(FieldName, true, FunctionName));
                    end;
                TokenType::Comma:
                    JFields.Add(GetFieldNode(FieldName, false, ''));
            end;
        end;

        if UpperCase(TokenValue) <> 'FROM' then
            Error(SyntaxErrorErr, 'FROM');

        exit(JFields);
    end;

    local procedure ReadToken(
        JTokens: JsonArray;
        var Pos: Integer;
        var TokenValue: Text;
        var TokenType: Enum "Inline Query Token Type"): Boolean
    var
        JToken: JsonToken;
    begin
        if Pos >= JTokens.Count() then
            exit(false);

        JTokens.Get(Pos, JToken);
        ReadTokenData(JToken.AsObject(), TokenValue, TokenType);
        Pos += 1;

        exit(true);
    end;

    local procedure PeekToken(
        JTokens: JsonArray;
        Pos: Integer;
        var TokenValue: Text;
        var TokenType: Enum "Inline Query Token Type"): Boolean
    var
        JToken: JsonToken;
    begin
        if Pos >= JTokens.Count() then
            exit(false);

        JTokens.Get(Pos, JToken);
        ReadTokenData(JToken.AsObject(), TokenValue, TokenType);

        exit(true);
    end;

    local procedure ReadTokenData(
        JObject: JsonObject;
        var TokenValue: Text;
        var TokenType: Enum "Inline Query Token Type")
    var
        JToken: JsonToken;
    begin
        if JObject.Get('Value', JToken) then
            TokenValue := JToken.AsValue().AsText();

        if JObject.Get('Type', JToken) then
            TokenType := "Inline Query Token Type".FromInteger(JToken.AsValue().AsInteger());
    end;

    local procedure GetFieldNode(Name: Text; IsFunction: Boolean; FunctionName: Text): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add('Field', Name);
        JObject.Add('IsFunction', IsFunction);
        if IsFunction then
            JObject.Add('Function', FunctionName);

        exit(JObject);
    end;

    local procedure GetFilterNode(FieldName: Text; Operator: Text; FilterValue: Text): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add('Field', FieldName);
        JObject.Add('Operator', Operator);
        JObject.Add('Filter', FilterValue);

        exit(JObject);
    end;

    local procedure GetTableNode(TableName: Text; Company: Text): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add('Table', TableName);
        JObject.Add('Company', Company);

        exit(JObject);
    end;
}