codeunit 50140 "Inline Query Test - Library"
{
    procedure SetupTestData()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
    begin
        InlineQueryTestData.DeleteAll();

        InsertDate(false, 20200101D, 015900T, CreateDateTime(20180325D, 115900T), 10, 10, 10.10, 'C001', 'Text001');
        InsertDate(true, 20200102D, 025900T, CreateDateTime(20200102D, 115900T), 20, 20, 20.10, 'C002', 'Text002');
        InsertDate(false, 20200103D, 035900T, CreateDateTime(20200103D, 115900T), 30, 30, 30.10, 'C003', 'Text003');
        InsertDate(true, 20200104D, 045900T, CreateDateTime(20200104D, 115900T), 40, 40, 40.10, 'C004', 'Text004');
        InsertDate(false, 20200105D, 055900T, CreateDateTime(20200105D, 115900T), 50, 50, 50.10, 'C005', 'Text005');
        InsertDate(true, 20200106D, 065900T, CreateDateTime(20200106D, 115900T), 60, 60, 60.10, 'C006', 'Text006');
        InsertDate(false, 20200107D, 075900T, CreateDateTime(20200107D, 115900T), 70, 70, 70.10, 'C007', 'Text007');
        InsertDate(true, 20200108D, 085900T, CreateDateTime(20200108D, 115900T), 80, 80, 80.10, 'C008', 'Text008');
        InsertDate(false, 20200109D, 095900T, CreateDateTime(20200109D, 115900T), 90, 90, 90.10, 'C009', 'Text009');
        InsertDate(true, 20200110D, 105900T, CreateDateTime(20200110D, 115900T), 100, 100, 100.10, 'C010', 'Text010');
    end;

    procedure DataToJson(var InlineQueryTestData: Record "Inline Query Test Data"): JsonArray
    var
        JRecords: JsonArray;
    begin
        if InlineQueryTestData.FindSet() then
            repeat
                JRecords.Add(GetRecordJson(InlineQueryTestData));
            until InlineQueryTestData.Next() = 0;

        exit(JRecords);
    end;

    local procedure GetRecordJson(var InlineQueryTestData: Record "Inline Query Test Data"): JsonObject
    var
        JRecord: JsonObject;
    begin
        JRecord.Add('C1', InlineQueryTestData."Boolean Value");
        JRecord.Add('C2', InlineQueryTestData."Time Value");
        JRecord.Add('C3', InlineQueryTestData."Date Value");
        JRecord.Add('C4', InlineQueryTestData."DateTime Value");
        JRecord.Add('C5', InlineQueryTestData."Integer Value");
        JRecord.Add('C6', InlineQueryTestData."BigInteger Value");
        JRecord.Add('C7', InlineQueryTestData."Decimal Value");
        JRecord.Add('C8', InlineQueryTestData."Code Value");
        JRecord.Add('C9', InlineQueryTestData."Text Value");
        JRecord.Add('C10', InlineQueryTestData."Guid Value");
        JRecord.Add('C11', InlineQueryTestData."Duration Value");
        JRecord.Add('C12', Format(InlineQueryTestData."RecordId Value", 0, 9));
        JRecord.Add('C13', InlineQueryTestData."Option Value");

        exit(JRecord);
    end;

    local procedure InsertDate(
        BoolValue: Boolean;
        DateValue: Date;
        TimeValue: Time;
        DateTimeValue: DateTime;
        IntValue: Integer;
        BigIntValue: BigInteger;
        DecValue: Decimal;
        CodeValue: Code[20];
        TxtValue: Text[100])
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();

        InlineQueryTestData.Init();
        InlineQueryTestData."Boolean Value" := BoolValue;
        InlineQueryTestData."Time Value" := TimeValue;
        InlineQueryTestData."Date Value" := DateValue;
        InlineQueryTestData."DateTime Value" := DateTimeValue;
        InlineQueryTestData."Integer Value" := IntValue;
        InlineQueryTestData."BigInteger Value" := BigIntValue;
        InlineQueryTestData."Decimal Value" := DecValue;
        InlineQueryTestData."Code Value" := CodeValue;
        InlineQueryTestData."Text Value" := TxtValue;

        InlineQueryTestData."Guid Value" := CreateGuid();
        InlineQueryTestData."Duration Value" := 50000;
        InlineQueryTestData."RecordId Value" := CompanyInfo.RecordId;
        InlineQueryTestData."Option Value" := InlineQueryTestData."Option Value"::One;
        InlineQueryTestData.Insert();
    end;
}