page 50100 "Inline Query Test"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            field(QueryType; QueryType)
            {
                ApplicationArea = All;
                ToolTip = 'Query Type';
                Caption = 'Qery Type';
                OptionCaption = 'Variant,RecordRef,JsonArray';
            }
            field("Inline Query"; QueryText)
            {
                ApplicationArea = All;
                ToolTip = 'Specify the Query Text';
                Caption = 'Inline Query';
            }
            field("Result"; Result)
            {
                Editable = false;
                MultiLine = true;
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
                    RecordRef: RecordRef;
                    JArray: JsonArray;
                    ValueVariant: Variant;
                begin
                    Result := '';
                    case QueryType of
                        QueryType::Variant:
                            begin
                                InlineQuery.AsVariant(QueryText, ValueVariant);
                                Result := Format(ValueVariant);
                            end;
                        QueryType::JsonArray:
                            begin
                                JArray := InlineQuery.AsJsonArray(QueryText);
                                JArray.WriteTo(Result);
                            end;
                        QueryType::RecordRef:
                            begin
                                InlineQuery.AsRecord(QueryText, RecordRef);
                                Result := RecordRef.GetView(true);
                            end;
                    end;
                end;
            }
        }
    }

    var
        InlineQuery: Codeunit "Inline Query";
        QueryType: Option Variant,RecordRef,JsonArray;
        QueryText: Text;
        Result: Text;
}