codeunit 50100 "Inline Query Tokenizer"
{
    Access = Internal;

    var
        IllegalCharacterErr: Label 'Syntax error, Illegal character ''%1'' at position %2.', Comment = '%1 = Character, %2 = Position';
        SyntaxErrorErr: Label 'Syntax error, %1 expected.', Comment = '%1 = Character';
        TokenValueTxt: Label 'Value', Locked = true;
        TokenTypeTxt: Label 'Type', Locked = true;

    procedure Tokenize(QueryText: Text): JsonArray;
    var
        Pos: Integer;
        Len: Integer;
        JTokens: JsonArray;
    begin
        QueryText := DelChr(QueryText, '<>', ' ');
        Len := StrLen(QueryText);
        Pos := 1;

        while Pos <= Len do
            JTokens.Add(ReadToken(QueryText, Pos));

        exit(JTokens);
    end;

    procedure PeekToken(
        JTokens: JsonArray;
        Pos: Integer;
        var TokenValue: Text;
        var TokenType: Enum "Inline Query Token Type";
        EndOfTokensError: Text): Boolean
    begin
        if not PeekToken(JTokens, Pos, TokenValue, TokenType) then
            Error(EndOfTokensError);

        exit(true);
    end;

    procedure PeekToken(
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
        ReadToken(JToken.AsObject(), TokenValue, TokenType);

        exit(true);
    end;

    procedure ReadToken(
        JTokens: JsonArray;
        var Pos: Integer;
        var TokenValue: Text;
        var TokenType: Enum "Inline Query Token Type";
        EndOfTokensError: Text): Boolean
    begin
        if not ReadToken(JTokens, Pos, TokenValue, TokenType) then
            Error(EndOfTokensError);

        exit(true);
    end;

    procedure ReadToken(
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
        ReadToken(JToken.AsObject(), TokenValue, TokenType);
        Pos += 1;

        exit(true);
    end;

    local procedure ReadToken(QueryText: Text; var Pos: Integer): JsonObject
    var
        Chr: Char;
        Len: Integer;
        TokenValue: Text;
    begin
        Len := StrLen(QueryText);
        Chr := QueryText[Pos];

        // Read white spaces
        while Chr in [9, 10, 13, 32] do begin
            Pos += 1;
            if Pos > Len then
                exit;

            Chr := QueryText[Pos];
        end;

        // COMMA
        if Chr = ',' then begin
            Pos += 1;
            exit(GetToken(Chr, "Inline Query Token Type"::Comma));
        end;

        // Period
        if Chr = '.' then begin
            Pos += 1;
            exit(GetToken(Chr, "Inline Query Token Type"::Period));
        end;

        // Equals
        if Chr = '=' then begin
            Pos += 1;
            exit(GetToken(Chr, "Inline Query Token Type"::"Equal To"));
        end;

        // Equals
        if Chr = '*' then begin
            Pos += 1;
            exit(GetToken(Chr, "Inline Query Token Type"::Star));
        end;

        // Open Parentheses 
        if Chr = '(' then begin
            Pos += 1;
            exit(GetToken(Chr, "Inline Query Token Type"::"Opening Parenthesis"));
        end;

        // Close Parentheses 
        if Chr = ')' then begin
            Pos += 1;
            exit(GetToken(Chr, "Inline Query Token Type"::"Closing Parenthesis"));
        end;

        // Less than
        if Chr = '<' then begin
            Pos += 1;

            if Pos <= Len then begin
                Chr := QueryText[Pos];
                if Chr = '=' then begin
                    Pos += 1;
                    exit(GetToken('<=', "Inline Query Token Type"::"Less Than or Equal To"));
                end;

                if Chr = '>' then begin
                    Pos += 1;
                    exit(GetToken('<>', "Inline Query Token Type"::"Not Equal To"));
                end;
            end;

            exit(GetToken('<', "Inline Query Token Type"::"Less Than"));
        end;

        // Greater than
        if Chr = '>' then begin
            Pos += 1;

            if Pos <= Len then begin
                Chr := QueryText[Pos];
                if Chr = '=' then begin
                    Pos += 1;
                    exit(GetToken('>=', "Inline Query Token Type"::"Greater Than or Equal To"));
                end;
            end;

            exit(GetToken('>', "Inline Query Token Type"::"Greater Than"));
        end;

        // Brackets
        if Chr = '[' then begin
            Pos += 1;
            Chr := QueryText[Pos];

            while (Chr <> ']') do begin
                TokenValue += Chr;
                Pos += 1;

                if Pos > Len then
                    Error(SyntaxErrorErr, ']');

                Chr := QueryText[Pos];
            end;

            Pos += 1;
            exit(GetToken(TokenValue, "Inline Query Token Type"::Identifier));
        end;

        // Constants
        if Chr = '''' then begin
            Pos += 1;
            Chr := QueryText[Pos];

            while (Chr <> '''') do begin
                TokenValue += Chr;
                Pos += 1;

                if Pos > Len then
                    Error(SyntaxErrorErr, '''');

                Chr := QueryText[Pos];
            end;

            Pos += 1;
            exit(GetToken(TokenValue, "Inline Query Token Type"::Constant));
        end;

        if ((Chr >= 'A') and (Chr <= 'Z')) or
          ((Chr >= 'a') and (Chr <= 'z'))
        then begin
            while ((Chr >= 'A') and (Chr <= 'Z')) or
              ((Chr >= 'a') and (Chr <= 'z')) or
              ((Chr >= '0') and (Chr <= '9')) or
              (Chr = '_')
            do begin
                TokenValue += QueryText[Pos];
                Pos += 1;

                if Pos > Len then
                    Break;

                Chr := QueryText[Pos];
            end;

            exit(GetToken(TokenValue, "Inline Query Token Type"::Identifier))
        end;

        // Number
        if (Chr >= '0') and (Chr <= '9') then begin
            while ((Chr >= '0') and (Chr <= '9')) or
              (Chr = '.')
            do begin
                TokenValue += QueryText[Pos];
                Pos += 1;

                if Pos > Len then
                    Break;

                Chr := QueryText[Pos];
            end;

            exit(GetToken(TokenValue, "Inline Query Token Type"::Number))
        end;

        Error(IllegalCharacterErr, Chr, Pos);
    end;

    local procedure GetToken(TokenValue: Text; TokenType: Enum "Inline Query Token Type"): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add(TokenValueTxt, TokenValue);
        JObject.Add(TokenTypeTxt, TokenType.AsInteger());
        exit(JObject);
    end;

    local procedure ReadToken(
        TokenObject: JsonObject;
        var TokenValue: Text;
        var TokenType: Enum "Inline Query Token Type")
    var
        JToken: JsonToken;
    begin
        if TokenObject.Get(TokenValueTxt, JToken) then
            TokenValue := JToken.AsValue().AsText();

        if TokenObject.Get(TokenTypeTxt, JToken) then
            TokenType := "Inline Query Token Type".FromInteger(JToken.AsValue().AsInteger());
    end;
}