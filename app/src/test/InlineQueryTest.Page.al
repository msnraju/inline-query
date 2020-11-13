page 50100 "Inline Query Test"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            field("Inline Query"; QueryText)
            {
                ApplicationArea = All;
                ToolTip = 'Specify the Query Text';
                Caption = 'Inline Query';
            }
            field("Result"; Result)
            {
                Editable = false;
                ApplicationArea = All;
                ToolTip = 'The Query Result';
                Caption = 'Result';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Execute")
            {
                ApplicationArea = All;
                Caption = 'Execute';
                ToolTip = 'Execute the Query';
                Image = Action;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ResultVariant: Variant;
                begin
                    Result := '';
                    InlineQuery.AsVariant(QueryText, ResultVariant);
                    Result := Format(ResultVariant);
                end;
            }
        }
    }

    var
        InlineQuery: Codeunit "Inline Query";
        QueryText: Text;
        Result: Text;
}