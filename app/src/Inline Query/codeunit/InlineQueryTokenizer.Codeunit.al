codeunit 50100 "Inline Query Tokenizer"
{
    Access = Internal;

    var
        IllegalCharacterErr: Label 'Syntax error, Illegal character ''%1'' at position %2.', Comment = '%1 = Character, %2 = Position';
        SyntaxErrorErr: Label 'Syntax error, %1 expected.', Comment = '%1 = Character';

    procedure Tokenize(QueryText: Text): JsonArray;
    var
        Pos: Integer;
        JTokens: JsonArray;
    begin
        Pos := 1;
        while Pos <= StrLen(QueryText) do
            JTokens.Add(ReadToken(QueryText, Pos));

        exit(JTokens);
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
        while Chr = ' ' do begin
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
              ((Chr >= '0') and (Chr <= '0')) or
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
        JObject.Add('Value', TokenValue);
        JObject.Add('Type', TokenType.AsInteger());
        exit(JObject);
    end;
}