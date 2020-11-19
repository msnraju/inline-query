codeunit 50130 "Inline Query Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        InlineQuery: Codeunit "Inline Query";
        InlineQueryTestLibrary: Codeunit "Inline Query Test - Library";

    [Test]
    procedure CountRecords()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        RecCount: Integer;
        RecCountFromQuery: Integer;
        QueryText: Label 'SELECT COUNT(1) FROM [Inline Query Test Data] WHERE [Boolean Value] = true', Locked = true;
        CountMisMatchErr: Label 'Record count should be equal to %1', Comment = '%1 = Record Count';
    begin
        // [SCENARIO] Inline Query should return count of records in the source table after applying filters.
        // [GIVEN] Inline Query that returns Count
        InlineQueryTestLibrary.SetupTestData();
        InlineQueryTestData.SetRange("Boolean Value", true);
        RecCount := InlineQueryTestData.Count();

        // [WHEN] Executing AsInteger method with select COUNT function in the Inline Query.
        RecCountFromQuery := InlineQuery.AsInteger(QueryText);

        // [THEN] Count from the AL Code and the Inline Query's return value should match
        Assert.AreEqual(RecCount, RecCountFromQuery, StrSubstNo(CountMisMatchErr, RecCount));
    end;

    [Test]
    procedure FirstTimeValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Time;
        ValueFromQuery: Time;
        QueryText: Label 'SELECT FIRST([Time Value]) FROM [Inline Query Test Data] WHERE [Integer Value] > 50', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should return first value from the source table after applying filters.
        // [GIVEN] Inline Query that returns first value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetFilter("Integer Value", '>50');
        InlineQueryTestData.FindFirst();
        ExpectedValue := InlineQueryTestData."Time Value";

        // [WHEN] Executing AsTime method with select FIRST function in the Inline Query.
        ValueFromQuery := InlineQuery.AsTime(QueryText);

        // [THEN] Time Value from the AL Code and the Inline Query's return value should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure FirstTextValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Text[100];
        ValueFromQuery: Text[100];
        QueryText: Label 'SELECT FIRST([Text Value]) FROM [Inline Query Test Data] WHERE [Integer Value] > 50', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should return first value from the source table after applying filters.
        // [GIVEN] Inline Query that returns first value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetFilter("Integer Value", '>50');
        InlineQueryTestData.FindFirst();
        ExpectedValue := InlineQueryTestData."Text Value";

        // [WHEN] Executing AsTime method with select FIRST function in the Inline Query.
        ValueFromQuery := InlineQuery.AsText(QueryText);

        // [THEN] Text Value from the AL Code and the Inline Query's return value should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure LastDateValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Date;
        ValueFromQuery: Date;
        QueryText: Label 'SELECT LAST([Date Value]) FROM [Inline Query Test Data] WHERE [Decimal Value] < 80', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should return last value from the source table after applying filters.
        // [GIVEN] Inline Query that returns last value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetFilter("Decimal Value", '<80');
        InlineQueryTestData.FindLast();
        ExpectedValue := InlineQueryTestData."Date Value";

        // [WHEN] Executing AsDate method with select LAST function in the Inline Query.
        ValueFromQuery := InlineQuery.AsDate(QueryText);

        // [THEN] Date Value from the AL Code and the Inline Query's return value should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure LastCodeValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Code[20];
        ValueFromQuery: Code[20];
        QueryText: Label 'SELECT LAST([Code Value]) FROM [Inline Query Test Data] WHERE [Decimal Value] < 80', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should return last value from the source table after applying filters.
        // [GIVEN] Inline Query that returns last value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetFilter("Decimal Value", '<80');
        InlineQueryTestData.FindLast();
        ExpectedValue := InlineQueryTestData."Code Value";

        // [WHEN] Executing AsCode method with select LAST function in the Inline Query.
        ValueFromQuery := InlineQuery.AsCode(QueryText);

        // [THEN] Code Value from the AL Code and the Inline Query's return value should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure LastBooleanValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Boolean;
        ValueFromQuery: Boolean;
        QueryText: Label 'SELECT LAST([Boolean Value]) FROM [Inline Query Test Data] WHERE [Decimal Value] < 80', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should return last value from the source table after applying filters.
        // [GIVEN] Inline Query that returns last value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetFilter("Decimal Value", '<80');
        InlineQueryTestData.FindLast();
        ExpectedValue := InlineQueryTestData."Boolean Value";

        // [WHEN] Executing AsBoolean method with select LAST function in the Inline Query.
        ValueFromQuery := InlineQuery.AsBoolean(QueryText);

        // [THEN] Code Value from the AL Code and the Inline Query's return value should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure MinBigIntegerValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Decimal;
        ValueFromQuery: Decimal;
        QueryText: Label 'SELECT MIN([BigInteger Value]) FROM [Inline Query Test Data] WHERE [Date Value] <= ''%1'' AND [Time Value] >= ''%2''', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should return min value from the source table after applying filters.
        // [GIVEN] Inline Query that returns min value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetCurrentKey("BigInteger Value");
        InlineQueryTestData.SetFilter("Date Value", '<=%1', 20200131D);
        InlineQueryTestData.SetFilter("Time Value", '>=%1', 045900T);
        InlineQueryTestData.FindFirst();
        ExpectedValue := InlineQueryTestData."BigInteger Value";

        // [WHEN] Executing AsBigInteger method with select MIN function in the Inline Query.
        ValueFromQuery := InlineQuery.AsBigInteger(StrSubstNo(QueryText, 20200131D, 045900T));

        // [THEN] BigInteger Value from the AL Code and the Inline Query's return value should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure MaxDateTimeValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: DateTime;
        ValueFromQuery: DateTime;
        QueryText: Label 'SELECT MAX([DateTime Value]) FROM [Inline Query Test Data] WHERE [Decimal Value] LIKE ''40.1|50.1''', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should return max value from the source table after applying filters.
        // [GIVEN] Inline Query that returns max value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetCurrentKey("DateTime Value");
        InlineQueryTestData.SetFilter("Decimal Value", '40.1|50.1');
        InlineQueryTestData.FindLast();
        ExpectedValue := InlineQueryTestData."DateTime Value";

        // [WHEN] Executing AsDateTime method with select MAX function in the Inline Query.
        ValueFromQuery := InlineQuery.AsDateTime(QueryText);

        // [THEN] DateTime Value from the AL Code and the Inline Query's return value should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure AvgDecimalValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Decimal;
        ValueFromQuery: Decimal;
        QueryText: Label 'SELECT AVG([Decimal Value]) FROM [Inline Query Test Data]', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should return avg value from the source table after applying filters.
        // [GIVEN] Inline Query that returns avg value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.CalcSums("Decimal Value");
        ExpectedValue := InlineQueryTestData."Decimal Value" / InlineQueryTestData.Count();

        // [WHEN] Executing AsDecimal method with select AVG function in the Inline Query.
        ValueFromQuery := InlineQuery.AsDecimal(QueryText);

        // [THEN] Decimal Value from the AL Code and the Inline Query's return value should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure SumIntegerValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Integer;
        ValueFromQuery: Integer;
        QueryText: Label 'SELECT SUM([Integer Value]) FROM [%1].[Inline Query Test Data] WHERE [Boolean Value] <> false', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should return sum of values from the source table after applying filters.
        // [GIVEN] Inline Query that returns sum value
        InlineQueryTestLibrary.SetupTestData();
        InlineQueryTestData.SetFilter("Boolean Value", '<>false');
        InlineQueryTestData.CalcSums("Integer Value");
        ExpectedValue := InlineQueryTestData."Integer Value";

        // [WHEN] Executing AsInteger method with select SUM function in the Inline Query.
        ValueFromQuery := InlineQuery.AsInteger(StrSubstNo(QueryText, CompanyName));

        // [THEN] Inline Query should return the expected quantity
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure OrderByTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Text;
        ValueFromQuery: Text;
        RecordRef: RecordRef;
        QueryText: Label 'SELECT [Integer Value], [BigInteger Value] FROM [Inline Query Test Data] WHERE [Boolean Value] <> false ORDER BY [Integer Value]', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should apply sorting and filters to the RecordRef parameter.
        // [GIVEN] Inline Query with Sorting and Filters
        InlineQueryTestLibrary.SetupTestData();
        InlineQueryTestData.SetCurrentKey("Integer Value");
        InlineQueryTestData.SetFilter("Boolean Value", '<>false');
        ExpectedValue := InlineQueryTestData.GetView(true);

        // [WHEN] Executing AsRecord method with sorting and filters in the Inline Query.
        InlineQuery.AsRecord(QueryText, RecordRef);
        ValueFromQuery := RecordRef.GetView(true);

        // [THEN] Inline Query should return the expected quantity
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure AsJsonTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        JExpectedValue: JsonArray;
        ExpectedValue: Text;
        JValueFromQuery: JsonArray;
        ValueFromQuery: Text;
        RecordRef: RecordRef;
        QueryText: Label 'SELECT [Boolean Value] AS C1, [Time Value] AS C2, [Date Value] AS C3, [DateTime Value] AS C4, [Integer Value] AS C5, [BigInteger Value] AS C6, [Decimal Value] AS C7, [Code Value] AS C8, [Text Value] AS C9, [Guid Value] AS C10, [Duration Value] AS C11, [RecordId Value] AS C12, [Option Value] AS C13 FROM [Inline Query Test Data] WHERE [Boolean Value] <> false ORDER BY [Integer Value]', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should export data from the source table to JsonArray
        // [GIVEN] Inline Query with Json property names
        InlineQueryTestLibrary.SetupTestData();
        InlineQueryTestData.SetCurrentKey("Integer Value");
        InlineQueryTestData.SetFilter("Boolean Value", '<>false');
        JExpectedValue := InlineQueryTestLibrary.DataToJson(InlineQueryTestData);
        JExpectedValue.WriteTo(ExpectedValue);

        // [WHEN] Executing AsJsonArray method
        JValueFromQuery := InlineQuery.AsJsonArray(QueryText);
        JValueFromQuery.WriteTo(ValueFromQuery);

        // [THEN] Inline Query should return the expected quantity
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure Top2RecordsTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        JExpectedValue: JsonArray;
        ExpectedValue: Text;
        JValueFromQuery: JsonArray;
        ValueFromQuery: Text;
        RecordRef: RecordRef;
        QueryText: Label 'SELECT TOP 2 [Boolean Value] AS C1, [Time Value] AS C2, [Date Value] AS C3, [DateTime Value] AS C4, [Integer Value] AS C5, [BigInteger Value] AS C6, [Decimal Value] AS C7, [Code Value] AS C8, [Text Value] AS C9, [Guid Value] AS C10, [Duration Value] AS C11, [RecordId Value] AS C12, [Option Value] AS C13 FROM [Inline Query Test Data] ORDER BY [Integer Value]', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should export TOP 2 records data from the source table to JsonArray
        // [GIVEN] Inline Query with Json property names
        InlineQueryTestLibrary.SetupTestData();
        InlineQueryTestData.SetCurrentKey("Integer Value");
        InlineQueryTestData.SetRange("Integer Value", 10, 20);
        JExpectedValue := InlineQueryTestLibrary.DataToJson(InlineQueryTestData);
        JExpectedValue.WriteTo(ExpectedValue);

        // [WHEN] Executing AsJsonArray method
        JValueFromQuery := InlineQuery.AsJsonArray(QueryText);
        JValueFromQuery.WriteTo(ValueFromQuery);

        // [THEN] Inline Query should return the expected quantity
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure Top2RecordsWithHeadersTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        JExpectedValue: JsonArray;
        ExpectedValue: Text;
        JValueFromQuery: JsonArray;
        ValueFromQuery: Text;
        RecordRef: RecordRef;
        JHeaders: JsonArray;
        QueryText: Label 'SELECT TOP 2 [Boolean Value] AS C1, [Time Value] AS C2, [Date Value] AS C3, [DateTime Value] AS C4, [Integer Value] AS C5, [BigInteger Value] AS C6, [Decimal Value] AS C7, [Code Value] AS C8, [Text Value] AS C9, [Guid Value] AS C10, [Duration Value] AS C11, [RecordId Value] AS C12, [Option Value] AS C13 FROM [Inline Query Test Data] ORDER BY [Integer Value]', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should export TOP 2 records data from the source table to JsonArray with headers
        // [GIVEN] Inline Query with Json property names
        InlineQueryTestLibrary.SetupTestData();
        InlineQueryTestData.SetCurrentKey("Integer Value");
        InlineQueryTestData.SetRange("Integer Value", 10, 20);
        JExpectedValue := InlineQueryTestLibrary.DataToJson(InlineQueryTestData);
        JExpectedValue.WriteTo(ExpectedValue);

        // [WHEN] Executing AsJsonArray method
        JValueFromQuery := InlineQuery.AsJsonArray(QueryText, JHeaders, false);
        JValueFromQuery.WriteTo(ValueFromQuery);

        // [THEN] Inline Query should return the expected quantity
        Assert.AreEqual(13, JHeaders.Count, StrSubstNo(ValueMisMatchErr, 13));
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure MultipleAggrFunctionsTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        JExpectedValue: JsonArray;
        ExpectedValue: Text;
        JValueFromQuery: JsonArray;
        ValueFromQuery: Text;
        RecordRef: RecordRef;
        JHeaders: JsonArray;
        QueryText: Label 'SELECT Sum([Integer Value]) AS C5, Sum([BigInteger Value]), Avg([Decimal Value]) AS C7 FROM [Inline Query Test Data]', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should export aggregate values from the source table to JsonArray
        // [GIVEN] Inline Query with Json property names
        InlineQueryTestLibrary.SetupTestData();
        ExpectedValue := '[{"C5":"550","Sum_of_BigInteger_Value":"550","C7":"55.1"}]';

        // [WHEN] Executing AsJsonArray method
        JValueFromQuery := InlineQuery.AsJsonArray(QueryText);
        JValueFromQuery.WriteTo(ValueFromQuery);

        // [THEN] Inline Query should return the expected quantity
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure AllFieldsFirstRecordTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        JExpectedValue: JsonArray;
        ExpectedValue: Text;
        JValueFromQuery: JsonArray;
        ValueFromQuery: Text;
        RecordRef: RecordRef;
        JHeaders: JsonArray;
        JToken: JsonToken;
        JRecord: JsonObject;
        QueryText: Label 'SELECT TOP 1 * FROM [Inline Query Test Data]', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value';
    begin
        // [SCENARIO] Inline Query should export all fields from the source table's first record to JsonArray
        // [GIVEN] Inline Query with Json property names
        InlineQueryTestLibrary.SetupTestData();
        InlineQueryTestData.FindFirst();

        // [WHEN] Executing AsJsonArray method
        JValueFromQuery := InlineQuery.AsJsonArray(QueryText);
        JValueFromQuery.Get(0, JToken);
        JRecord := JToken.AsObject();

        // [THEN] Inline Query should return the expected quantity
        JRecord.Get('Entry_No_', JToken);
        Assert.AreEqual(InlineQueryTestData."Entry No.", JToken.AsValue().AsInteger(), StrSubstNo(ValueMisMatchErr, InlineQueryTestData."Entry No."));

        JRecord.Get('Code_Value', JToken);
        Assert.AreEqual(InlineQueryTestData."Code Value", JToken.AsValue().AsCode(), StrSubstNo(ValueMisMatchErr, InlineQueryTestData."Code Value"));

        JRecord.Get('Text_Value', JToken);
        Assert.AreEqual(InlineQueryTestData."Text Value", JToken.AsValue().AsText(), StrSubstNo(ValueMisMatchErr, InlineQueryTestData."Text Value"));
    end;
}