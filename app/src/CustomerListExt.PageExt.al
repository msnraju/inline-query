pageextension 50100 "Customer List Ext" extends "Customer List"
{
    trigger OnOpenPage()
    var
        InlineQuery: Codeunit "Inline Query";
        QueryTxt: Label 'SELECT COUNT(1) FROM [Customer] WHERE [Responsibility Center] = ''BIRMINGHAM''';
    begin
        Message('Value: %1', InlineQuery.AsInteger(QueryTxt));
    end;
}