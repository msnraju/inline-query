codeunit 50102 "Inline Query Parser"
{
    Access = Internal;

    var
        InlineQueryTokenizer: Codeunit "Inline Query Tokenizer";
        InlineQueryJsonHelper: Codeunit "Inline Query Json Helper";
        InvalidQueryErr: Label 'Invalid query ''%1''', Comment = '%1 = Query Text';
        InvalidSyntaxNearErr: Label 'Incorrect syntax near ''%1''.', Comment = '%1 = Token Value';
        NotImplementedErr: Label 'Query type ''%1'' not implemented.', Comment = '%1 = Query Type';
        SelectKeywordTxt: Label 'SELECT', Locked = true;
        TopKeywordTxt: Label 'TOP', Locked = true;
        WhereKeywordTxt: Label 'WHERE', Locked = true;
        AndKeywordTxt: Label 'AND', Locked = true;
        LikeKeywordTxt: Label 'LIKE', Locked = true;
        OrderKeywordTxt: Label 'ORDER', Locked = true;
        ByKeywordTxt: Label 'BY', Locked = true;
        FromKeywordTxt: Label 'FROM', Locked = true;
        AsKeywordTxt: Label 'AS', Locked = true;

    procedure Parse(QueryText: Text; JTokens: JsonArray): JsonObject
    var
        Pos: Integer;
        QueryType: Enum "Inline Query Type";
    begin
        if JTokens.Count() = 0 then
            exit;

        Pos := 0;

        QueryType := GetQueryType(QueryText, JTokens, Pos);

        case QueryType of
            QueryType::Select:
                exit(ParseSelectQuery(JTokens, Pos));
            else
                Error(NotImplementedErr, QueryType);
        end;
    end;

    local procedure ParseSelectQuery(JTokens: JsonArray; var Pos: Integer): JsonObject
    var
        Top: Integer;
        JTable: JsonObject;
        JFields: JsonArray;
        JFilters: JsonArray;
        JOrderByFields: JsonArray;
    begin
        Top := ParseTopClause(JTokens, Pos);
        JFields := ParseFields(JTokens, Pos);
        JTable := ParseTable(JTokens, Pos);
        JFilters := ParseFilters(JTokens, Pos);
        JOrderByFields := ParseOrderBy(JTokens, Pos);
        EndOfQuery(JTokens, Pos);

        exit(InlineQueryJsonHelper.AsSelectQuery(Top, JFields, JTable, JFilters, JOrderByFields));
    end;

    local procedure ParseTopClause(JTokens: JsonArray; var Pos: Integer): Integer
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
        Top: Integer;
    begin
        if not InlineQueryTokenizer.PeekToken(JTokens, Pos, TokenValue, TokenType) then
            exit;

        if UpperCase(TokenValue) <> TopKeywordTxt then
            exit;

        Pos += 1;
        InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));

        if not Evaluate(Top, TokenValue) then
            Error(InvalidSyntaxNearErr, TokenValue);

        exit(Top);
    end;

    local procedure EndOfQuery(JTokens: JsonArray; Pos: Integer)
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
    begin
        if Pos = JTokens.Count() then
            exit;

        InlineQueryTokenizer.PeekToken(JTokens, Pos, TokenValue, TokenType);
        Error(InvalidSyntaxNearErr, TokenValue);
    end;

    local procedure GetQueryType(QueryText: Text; JTokens: JsonArray; var Pos: Integer): Enum "Inline Query type"
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
    begin
        InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidQueryErr, QueryText));
        case UpperCase(TokenValue) of
            SelectKeywordTxt:
                exit("Inline Query Type"::Select);
            else
                Error(InvalidQueryErr, QueryText);
        end;
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
        if not InlineQueryTokenizer.PeekToken(JTokens, Pos, TokenValue, TokenType) then
            exit;

        if UpperCase(TokenValue) <> WhereKeywordTxt then
            exit;

        Pos += 1;

        while (UpperCase(TokenValue) = WhereKeywordTxt) or (UpperCase(TokenValue) = AndKeywordTxt) do begin
            InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
            FieldName := TokenValue;

            InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
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
                    if UpperCase(TokenValue) <> LikeKeywordTxt then
                        Error(InvalidSyntaxNearErr, TokenValue);
            end;

            InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
            FilterValue := TokenValue;
            JFilters.Add(InlineQueryJsonHelper.AsFilter(FieldName, Operator, FilterValue));

            if not InlineQueryTokenizer.PeekToken(JTokens, Pos, TokenValue, TokenType) then
                Break;

            if UpperCase(TokenValue) = AndKeywordTxt then
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
        if not InlineQueryTokenizer.PeekToken(JTokens, Pos, TokenValue, TokenType) then
            exit;

        if UpperCase(TokenValue) <> OrderKeywordTxt then
            exit;

        Pos += 1;

        InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
        if UpperCase(TokenValue) <> ByKeywordTxt then
            Error(InvalidSyntaxNearErr, TokenValue);

        while (UpperCase(TokenValue) = ByKeywordTxt) or (TokenValue = ',') do begin
            InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));

            FieldName := TokenValue;
            JFields.Add(FieldName);

            if not InlineQueryTokenizer.PeekToken(JTokens, Pos, TokenValue, TokenType) then
                Break;

            if TokenType = TokenType::Comma then
                Pos += 1;
        end;

        exit(JFields);
    end;

    local procedure ParseTable(JTokens: JsonArray; var Pos: Integer): JsonObject
    var
        TokenValue: Text;
        TableName: Text;
        CompanyNameValue: Text;
        TokenType: Enum "Inline Query Token Type";
    begin
        InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
        TableName := TokenValue;

        if InlineQueryTokenizer.PeekToken(JTokens, Pos, TokenValue, TokenType) then
            if TokenType = TokenType::Period then begin
                Pos += 1;
                InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
                CompanyNameValue := TableName;
                TableName := TokenValue;
            end;


        exit(InlineQueryJsonHelper.AsSourceTable(TableName, CompanyNameValue));
    end;

    local procedure ParseFields(JTokens: JsonArray; var Pos: Integer): JsonArray
    var
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
        JFields: JsonArray;
    begin
        while (TokenValue = '') or (TokenType = TokenType::Comma) do begin
            JFields.Add(ParseField(JTokens, Pos));

            InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
            if UpperCase(TokenValue) = FromKeywordTxt then
                Break;

            if TokenType <> TokenType::Comma then
                Error(InvalidSyntaxNearErr, TokenValue);
        end;

        if UpperCase(TokenValue) <> FromKeywordTxt then
            Error(InvalidSyntaxNearErr, TokenValue);

        exit(JFields);
    end;

    local procedure ParseField(JTokens: JsonArray; var Pos: Integer): JsonObject
    var
        FieldName: Text;
        Name: Text;
        FunctionName: Text;
        IsFunction: Boolean;
        TokenValue: Text;
        TokenType: Enum "Inline Query Token Type";
    begin
        InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
        if TokenType = TokenType::Star then
            exit(InlineQueryJsonHelper.AsSelectAllFields());

        FieldName := TokenValue;
        InlineQueryTokenizer.PeekToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
        if TokenType = TokenType::"Opening Parenthesis" then begin
            Pos += 1;
            FunctionName := FieldName;
            IsFunction := true;

            InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
            FieldName := TokenValue;

            InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
            if TokenType <> TokenType::"Closing Parenthesis" then
                Error(InvalidSyntaxNearErr, TokenValue);

            InlineQueryTokenizer.PeekToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
        end;

        if UpperCase(TokenValue) = AsKeywordTxt then begin
            Pos += 1;
            InlineQueryTokenizer.ReadToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
            Name := TokenValue;

            InlineQueryTokenizer.PeekToken(JTokens, Pos, TokenValue, TokenType, StrSubstNo(InvalidSyntaxNearErr, TokenValue));
        end;

        exit(InlineQueryJsonHelper.AsSelectField(FieldName, IsFunction, FunctionName, Name));
    end;
}