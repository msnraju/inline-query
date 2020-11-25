codeunit 50105 "Inline Query Json Helper"
{
    Access = Internal;

    var
        QueryTypeTxt: Label 'QueryType', Locked = true;
        Select_Top_Txt: Label 'Top', Locked = true;
        Select_Fields_Txt: Label 'Fields', Locked = true;
        Select_Table_Txt: Label 'Table', Locked = true;
        Select_Filters_Txt: Label 'Filters', Locked = true;
        Select_OrderBy_Txt: Label 'OrderBy', Locked = true;
        Source_Table_Name_Txt: Label 'Table', Locked = true;
        Source_Table_Company_Txt: Label 'Company', Locked = true;
        Select_Field_Name_Txt: Label 'Field', Locked = true;
        Select_Field_AllFields_Txt: Label 'AllFields', Locked = true;
        Select_Field_IsFunction_Txt: Label 'IsFunction', Locked = true;
        Select_Field_FunctionName_Txt: Label 'Function', Locked = true;
        Select_Field_AliasName_Txt: Label 'Name', Locked = true;
        Filter_Field_Txt: Label 'Field', Locked = true;
        Filter_Operator_Txt: Label 'Operator', Locked = true;
        Filter_Value_Txt: Label 'Filter', Locked = true;
        Select_Header_Caption_Txt: Label 'Caption', Locked = true;
        Select_Header_Name_Txt: Label 'Name', Locked = true;

    procedure GetQueryType(JQueryNode: JsonObject): Enum "Inline Query Type"
    var
        JToken: JsonToken;
    begin
        if JQueryNode.Get(QueryTypeTxt, JToken) then
            exit("Inline Query Type".FromInteger(JToken.AsValue().AsInteger()));
    end;

    procedure AsSelectQuery(
        Top: Integer;
        JFields: JsonArray;
        JTable: JsonObject;
        JFilters: JsonArray;
        JOrderByFields: JsonArray): JsonObject
    var
        JQueryNode: JsonObject;
    begin
        JQueryNode.Add(QueryTypeTxt, "Inline Query Type"::Select.AsInteger());
        JQueryNode.Add(Select_Top_Txt, Top);
        JQueryNode.Add(Select_Fields_Txt, JFields);
        JQueryNode.Add(Select_Table_Txt, JTable);
        JQueryNode.Add(Select_Filters_Txt, JFilters);
        JQueryNode.Add(Select_OrderBy_Txt, JOrderByFields);

        exit(JQueryNode);
    end;

    procedure ReadSelectQuery(
        JQueryNode: JsonObject;
        var Top: Integer;
        var JFields: JsonArray;
        var JTable: JsonObject;
        var JFilters: JsonArray;
        var JOrderByFields: JsonArray)
    var
        JToken: JsonToken;
    begin
        if JQueryNode.Get(Select_Top_Txt, JToken) then
            Top := JToken.AsValue().AsInteger();

        if JQueryNode.Get(Select_Fields_Txt, JToken) then
            JFields := JToken.AsArray();

        if JQueryNode.Get(Select_Table_Txt, JToken) then
            JTable := JToken.AsObject();

        if JQueryNode.Get(Select_Filters_Txt, JToken) then
            JFilters := JToken.AsArray();

        if JQueryNode.Get(Select_OrderBy_Txt, JToken) then
            JOrderByFields := JToken.AsArray();
    end;

    procedure AsSourceTable(TableName: Text; Company: Text): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add(Source_Table_Name_Txt, TableName);
        JObject.Add(Source_Table_Company_Txt, Company);

        exit(JObject);
    end;

    procedure AsSourceTable(TableID: Integer; Company: Text): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add(Source_Table_Name_Txt, TableID);
        JObject.Add(Source_Table_Company_Txt, Company);

        exit(JObject);
    end;

    procedure ReadSourceTable(JTable: JsonObject; var TableName: Text; var CompanyName: Text)
    var
        JToken: JsonToken;
    begin
        if JTable.Get(Source_Table_Name_Txt, JToken) then
            TableName := JToken.AsValue().AsText();

        if JTable.Get(Source_Table_Company_Txt, JToken) then
            CompanyName := JToken.AsValue().AsText();
    end;

    procedure ReadSourceTable(JTable: JsonObject; var TableID: Integer; var CompanyName: Text)
    var
        JToken: JsonToken;
    begin
        if JTable.Get(Source_Table_Name_Txt, JToken) then
            TableID := JToken.AsValue().AsInteger();

        if JTable.Get(Source_Table_Company_Txt, JToken) then
            CompanyName := JToken.AsValue().AsText();
    end;

    procedure AsSelectField(FieldName: Text; IsFunction: Boolean; FunctionName: Text; Name: Text): JsonObject
    var
        JField: JsonObject;
    begin
        JField.Add(Select_Field_Name_Txt, FieldName);
        JField.Add(Select_Field_IsFunction_Txt, IsFunction);
        if IsFunction then
            JField.Add(Select_Field_FunctionName_Txt, FunctionName);

        JField.Add(Select_Field_AliasName_Txt, Name);

        exit(JField);
    end;

    procedure AsSelectAllFields(): JsonObject
    var
        JField: JsonObject;
    begin
        JField.Add(Select_Field_AllFields_Txt, true);
        exit(JField);
    end;

    procedure AsSelectField(
        FieldID: Integer;
        IsFunction: Boolean;
        FunctionType: Enum "Inline Query Function Type";
        AliasName: Text): JsonObject
    var
        JField: JsonObject;
    begin
        JField.Add(Select_Field_Name_Txt, FieldID);
        JField.Add(Select_Field_IsFunction_Txt, IsFunction);
        if IsFunction then
            JField.Add(Select_Field_FunctionName_Txt, FunctionType.AsInteger());

        JField.Add(Select_Field_AliasName_Txt, AliasName);

        exit(JField);
    end;

    procedure ReadSelectAllFields(JField: JsonObject): Boolean
    var
        JToken: JsonToken;
    begin
        if JField.Get(Select_Field_AllFields_Txt, JToken) then
            exit(JToken.AsValue().AsBoolean());

        exit(false);
    end;

    procedure ReadSelectField(
        JField: JsonObject;
        var FieldName: Text;
        var IsFunction: Boolean;
        var FunctionName: Text;
        var AliasName: Text)
    var
        JToken: JsonToken;
    begin
        if JField.Get(Select_Field_Name_Txt, JToken) then
            FieldName := JToken.AsValue().AsText();

        if JField.Get(Select_Field_IsFunction_Txt, JToken) then
            IsFunction := JToken.AsValue().AsBoolean();

        if JField.Get(Select_Field_FunctionName_Txt, JToken) then
            FunctionName := JToken.AsValue().AsText();

        if JField.Get(Select_Field_AliasName_Txt, JToken) then
            AliasName := JToken.AsValue().AsText();
    end;

    procedure ReadSelectField(
        JField: JsonObject;
        var FieldID: Integer;
        var IsFunction: Boolean;
        var FunctionType: Enum "Inline Query Function Type";
        var AliasName: Text)
    var
        JToken: JsonToken;
    begin
        if JField.Get(Select_Field_Name_Txt, JToken) then
            FieldID := JToken.AsValue().AsInteger();

        if JField.Get(Select_Field_IsFunction_Txt, JToken) then
            IsFunction := JToken.AsValue().AsBoolean();

        if JField.Get(Select_Field_FunctionName_Txt, JToken) then
            FunctionType := "Inline Query Function Type".FromInteger(JToken.AsValue().AsInteger());

        if JField.Get(Select_Field_AliasName_Txt, JToken) then
            AliasName := JToken.AsValue().AsText();
    end;

    procedure ReadSelectFieldIsFunction(JField: JsonObject): Boolean
    var
        JToken: JsonToken;
        IsFunction: Boolean;
    begin
        if JField.Get(Select_Field_IsFunction_Txt, JToken) then
            IsFunction := JToken.AsValue().AsBoolean();

        exit(IsFunction);
    end;

    procedure AsFilter(FieldName: Text; Operator: Text; FilterValue: Text): JsonObject
    var
        JFilter: JsonObject;
    begin
        JFilter.Add(Filter_Field_Txt, FieldName);
        JFilter.Add(Filter_Operator_Txt, Operator);
        JFilter.Add(Filter_Value_Txt, FilterValue);

        exit(JFilter);
    end;

    procedure AsFilter(FieldID: Integer; Operator: Enum "Inline Query Operator Type"; FilterValue: Text): JsonObject
    var
        JFilter: JsonObject;
    begin
        JFilter.Add(Filter_Field_Txt, FieldID);
        JFilter.Add(Filter_Operator_Txt, Operator.AsInteger());
        JFilter.Add(Filter_Value_Txt, FilterValue);

        exit(JFilter);
    end;

    procedure ReadFilter(
        JFilter: JsonObject;
        var FieldName: Text;
        var Operator: Text;
        var FilterValue: Text)
    var
        JToken: JsonToken;
    begin
        if JFilter.Get(Filter_Field_Txt, JToken) then
            FieldName := JToken.AsValue().AsText();

        if JFilter.Get(Filter_Operator_Txt, JToken) then
            Operator := JToken.AsValue().AsText();

        if JFilter.Get(Filter_Value_Txt, JToken) then
            FilterValue := JToken.AsValue().AsText();
    end;

    procedure ReadFilter(
        JFilter: JsonObject;
        var FieldID: Integer;
        var Operator: Enum "Inline Query Operator Type";
        var FilterValue: Text)
    var
        JToken: JsonToken;
    begin
        if JFilter.Get(Filter_Field_Txt, JToken) then
            FieldID := JToken.AsValue().AsInteger();

        if JFilter.Get(Filter_Operator_Txt, JToken) then
            Operator := "Inline Query Operator Type".FromInteger(JToken.AsValue().AsInteger());

        if JFilter.Get(Filter_Value_Txt, JToken) then
            FilterValue := JToken.AsValue().AsText();
    end;

    procedure AsGridHeader(Caption: Text; Name: Text): JsonObject
    var
        JFieldHeader: JsonObject;
    begin
        JFieldHeader.Add(Select_Header_Caption_Txt, Caption);
        JFieldHeader.Add(Select_Header_Name_Txt, Name);
        exit(JFieldHeader);
    end;
}