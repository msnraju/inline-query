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
                    ExecuteQuery(QueryText);
                end;
            }
        }
    }

    local procedure ExecuteQuery(QueryText: Text)
    var
        TryInlineQuery: Codeunit "Try Inline Query";
        JResult: JsonArray;
        JFieldHeaders: JsonArray;
    begin
        TryInlineQuery.SetQuery(QueryText);
        if not TryInlineQuery.Run() then begin
            CurrPage.QueryAnalyzerControlAddIn.UpdateError(QueryText, GetLastErrorText);
            exit;
        end;

        JResult := TryInlineQuery.GetResult();
        CurrPage.QueryAnalyzerControlAddIn.UpdateResults(QueryText, JFieldHeaders, JResult);
    end;
}