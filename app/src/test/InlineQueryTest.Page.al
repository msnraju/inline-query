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
                begin
                    InlineQuery.AsInteger(QueryText);
                end;
            }
        }
    }

    var
        InlineQuery: Codeunit "Inline Query";
        QueryText: Text;
}