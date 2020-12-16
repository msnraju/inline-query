codeunit 50106 "Try Inline Query"
{
    trigger OnRun()
    var
        InlineQuery: Codeunit "Inline Query";
        JFieldHeaders: JsonArray;
    begin
        JResult := InlineQuery.AsJsonArray(QueryText, JFieldHeaders, true);
    end;

    procedure SetQuery(NewQueryText: Text)
    begin
        QueryText := NewQueryText;
    end;

    procedure GetResult(): JsonArray
    begin
        exit(JResult);
    end;

    var
        QueryText: Text;
        JResult: JsonArray;
}