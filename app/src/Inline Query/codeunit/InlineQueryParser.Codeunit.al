codeunit 50102 "Inline Query Parser"
{
    Access = Internal;

    var
        SyntaxErrorErr: Label 'Syntax error, %1 expected.', Comment = '%1 = Token';
        InvalidTokenErrorErr: Label 'Syntax error, Invalid token ''%1''.', Comment = '%1 = Token';
        InvalidOperatorErr: Label 'Syntax error, Invalid operator ''%1''.', Comment = '%1 = Operator';

    procedure Parse(JTokens: JsonArray): JsonObject
    var
        Pos: Integer;
        Top: Integer;
        JTable: JsonObject;
        JFields: JsonArray;
        JFilters: JsonArray;
        JOrderByFields: JsonArray;
        JASTNode: JsonObject;
    begin
        if JTokens.Count() = 0 then
            exit;

        Pos := 0;

        ParseQueryType(JTokens, Pos);
        Top := ParseTopClause(JTokens, Pos);
        JFields := ParseFields(JTokens, Pos);
        JTable := ParseTable(JTokens, Pos);
        JFilters := ParseFilters(JTokens, Pos);
        JOrderByFields := ParseOrderBy(JTokens, Pos);

        EndOfQuery(JTokens, Pos);
        JASTNode.Add('Top', Top);
        JASTNode.Add('Fields', JFields);
        JASTNode.Add('Table', JTable);
        JASTNode.Add('Filters', JFilters);
        JASTNode.Add('OrderBy', JOrderByFields);

        exit(JASTNode);
    end;

    local procedure ParseTopClause(JTokens: JsonArray; var Pos: Integer): Integer
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
        Top: Integer;
    begin
        if not PeekToken(JTokens, Pos, TokenValue, TokenType) then
            exit;

        if UpperCase(TokenValue) <> 'TOP' then
            exit;

        Pos += 1;

        if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
            Error(SyntaxErrorErr, 'TOP');

        if not Evaluate(Top, TokenValue) then
            Error(SyntaxErrorErr, 'TOP');

        exit(Top);
    end;

    local procedure EndOfQuery(JTokens: JsonArray; Pos: Integer)
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
    begin
        if Pos = JTokens.Count() then
            exit;

        PeekToken(JTokens, Pos, TokenValue, TokenType);
        Error(InvalidTokenErrorErr, TokenValue);
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
            exit;

        Pos += 1;

        while (UpperCase(TokenValue) = 'WHERE') or (UpperCase(TokenValue) = 'AND') do begin
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

            if not PeekToken(JTokens, Pos, TokenValue, TokenType) then
                Break;

            if UpperCase(TokenValue) = 'AND' then
                Pos += 1;
        end;

        exit(JFilters);
    end;

    local procedure ParseOrderBy(JTokens: JsonArray; var Pos: Integer): JsonArray
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
        FieldName: Text;
        JFields: JsonArray;
    begin
        if not PeekToken(JTokens, Pos, TokenValue, TokenType) then
            exit;

        if UpperCase(TokenValue) <> 'ORDER' then
            exit;

        Pos += 1;

        if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
            Error(SyntaxErrorErr, 'ORDER');

        if UpperCase(TokenValue) <> 'BY' then
            Error(SyntaxErrorErr, 'BY');


        while (UpperCase(TokenValue) = 'BY') or (TokenValue = ',') do begin
            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'Field');

            FieldName := TokenValue;
            JFields.Add(FieldName);

            if not PeekToken(JTokens, Pos, TokenValue, TokenType) then
                Break;

            if TokenValue = ',' then
                Pos += 1;
        end;

        exit(JFields);
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
        JFields: JsonArray;
    begin
        while (TokenValue = '') or (TokenValue = ',') do begin
            JFields.Add(ParseField(JTokens, Pos));

            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'FROM');

            if UpperCase(TokenValue) = 'FROM' then
                Break;

            if UpperCase(TokenValue) <> ',' then
                Error(SyntaxErrorErr, 'FROM');
        end;

        if UpperCase(TokenValue) <> 'FROM' then
            Error(SyntaxErrorErr, 'FROM');

        exit(JFields);
    end;

    local procedure ParseField(JTokens: JsonArray; var Pos: Integer): JsonObject
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
        FieldName: Text;
        Name: Text;
        FunctionName: Text;
        IsFunction: Boolean;
    begin
        if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
            Error(SyntaxErrorErr, 'Field');

        FieldName := TokenValue;

        if not PeekToken(JTokens, Pos, TokenValue, TokenType) then
            Error(SyntaxErrorErr, 'Field');

        if TokenType = TokenType::"Opening Parenthesis" then begin
            Pos += 1;
            FunctionName := FieldName;
            IsFunction := true;

            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'Field');

            FieldName := TokenValue;
            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, ')');

            if TokenType <> TokenType::"Closing Parenthesis" then
                Error(SyntaxErrorErr, ')');

            if not PeekToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'Field');
        end;

        if UpperCase(TokenValue) = 'AS' then begin
            Pos += 1;
            if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'Field');

            Name := TokenValue;

            if not PeekToken(JTokens, Pos, TokenValue, TokenType) then
                Error(SyntaxErrorErr, 'Field');
        end;

        exit(GetFieldNode(FieldName, IsFunction, FunctionName, Name));
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

    local procedure GetFieldNode(FieldName: Text; IsFunction: Boolean; FunctionName: Text; Name: Text): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add('Field', FieldName);
        JObject.Add('IsFunction', IsFunction);
        if IsFunction then
            JObject.Add('Function', FunctionName);
        JObject.Add('Name', Name);
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