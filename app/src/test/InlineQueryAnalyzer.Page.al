page 50100 "Inline Query Analyzer"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            usercontrol(QueryAnalyzerControlAddIn; QueryAnalyzerControlAddIn)
            {
                trigger ControlAddInReady()
                begin
                end;

                trigger ExecuteQuery(QueryText: Text)
                begin
                    if not ExecuteQuery(QueryText) then
                        CurrPage.QueryAnalyzerControlAddIn.UpdateError(QueryText, GetLastErrorText);
                end;
            }
        }
    }

    [TryFunction]
    local procedure ExecuteQuery(QueryText: Text)
    var
        InlineQuery: Codeunit "Inline Query";
        JRows: JsonArray;
        JFieldHeaders: JsonArray;
    begin
        JRows := InlineQuery.AsJsonArray(QueryText, JFieldHeaders, true);
        CurrPage.QueryAnalyzerControlAddIn.UpdateResults(QueryText, JFieldHeaders, JRows);
    end;
}