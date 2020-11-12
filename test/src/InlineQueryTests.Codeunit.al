codeunit 50130 "Inline Query Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        InlineQuery: Codeunit "Inline Query";
        InlineQueryTestLibrary: Codeunit "Inline Query Test - Library";

    local procedure GetOrderCount(): Integer
    var
        InlineQuery: Codeunit "Inline Query";
        OrderCount: Integer;
        QueryTxt: Label 'SELECT COUNT(1) FROM [Sales Header] WHERE Status = ''Released''', Locked = true;
    begin
        OrderCount := InlineQuery.AsInteger(QueryTxt);
        exit(OrderCount);
    end;


    [Test]
    procedure CountRecords()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        RecCount: Integer;
        RecCountFromQuery: Integer;
        QueryText: Label 'SELECT COUNT(1) FROM [Inline Query Test Data] WHERE [Boolean Value] = true', Locked = true;
        CountMisMatchErr: Label 'Record count should be equal to %1', Comment = '%1 = Record Count
        // [SCENARIO] Inline Query should return count of records in the source table after applying filters.
        // [GIVEN] Inline Query that returns Count
eturns Count
        InlineQueryTestLibrary.SetupTestData();
        InlineQueryTestData.SetRange("Boolean Value", true);
        RecCount := InlineQueryTestD

        // [WHEN] Executing AsInteger method with select COUNT function in the Inline Query.
nline Query.
        RecCountFromQuery := InlineQuery.AsInteger

        // [THEN] Count from the AL Code and the Inline Query's return value should match
should match
        Assert.AreEqual(RecCount, RecCountFromQuery, StrSubstNo(CountMisMatchErr, RecCount));
    end;

    [Test]
    procedure FirstTimeValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Time;
        ValueFromQuery: Time;
        QueryText: Label 'SELECT FIRST([Time Value]) FROM [Inline Query Test Data] WHERE [Integer Value] > 50', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value
        // [SCENARIO] Inline Query should return first value from the source table after applying filters.
        // [GIVEN] Inline Query that returns first value
 first value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetFilter("Integer Value", '>50');
        InlineQueryTestData.FindFirst();
        ExpectedValue := InlineQueryTestData."

        // [WHEN] Executing AsTime method with select FIRST function in the Inline Query.
nline Query.
        ValueFromQuery := InlineQuery.AsTime

        // [THEN] Time Value from the AL Code and the Inline Query's return value should match
should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure FirstTextValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Text[100];
        ValueFromQuery: Text[100];
        QueryText: Label 'SELECT FIRST([Text Value]) FROM [Inline Query Test Data] WHERE [Integer Value] > 50', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value
        // [SCENARIO] Inline Query should return first value from the source table after applying filters.
        // [GIVEN] Inline Query that returns first value
 first value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetFilter("Integer Value", '>50');
        InlineQueryTestData.FindFirst();
        ExpectedValue := InlineQueryTestData."

        // [WHEN] Executing AsTime method with select FIRST function in the Inline Query.
nline Query.
        ValueFromQuery := InlineQuery.AsText

        // [THEN] Text Value from the AL Code and the Inline Query's return value should match
should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure LastDateValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Date;
        ValueFromQuery: Date;
        QueryText: Label 'SELECT LAST([Date Value]) FROM [Inline Query Test Data] WHERE [Decimal Value] < 80', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value
        // [SCENARIO] Inline Query should return last value from the source table after applying filters.
        // [GIVEN] Inline Query that returns last value
s last value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetFilter("Decimal Value", '<80');
        InlineQueryTestData.FindLast();
        ExpectedValue := InlineQueryTestData."

        // [WHEN] Executing AsDate method with select LAST function in the Inline Query.
nline Query.
        ValueFromQuery := InlineQuery.AsDate

        // [THEN] Date Value from the AL Code and the Inline Query's return value should match
should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure LastCodeValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Code[20];
        ValueFromQuery: Code[20];
        QueryText: Label 'SELECT LAST([Code Value]) FROM [Inline Query Test Data] WHERE [Decimal Value] < 80', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value
        // [SCENARIO] Inline Query should return last value from the source table after applying filters.
        // [GIVEN] Inline Query that returns last value
s last value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetFilter("Decimal Value", '<80');
        InlineQueryTestData.FindLast();
        ExpectedValue := InlineQueryTestData."

        // [WHEN] Executing AsCode method with select LAST function in the Inline Query.
nline Query.
        ValueFromQuery := InlineQuery.AsCode

        // [THEN] Code Value from the AL Code and the Inline Query's return value should match
should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure LastBooleanValueTest()
    var
        InlineQueryTestData: Record "Inline Query
ta";        
        ExpectedValue: Boolean;
        ValueFromQuery: Boolean;
        QueryText: Label 'SELECT LAST([Boolean Value]) FROM [Inline Query Test Data] WHERE [Decimal Value] < 80', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value
        // [SCENARIO] Inline Query should return last value from the source table after applying filters.
        // [GIVEN] Inline Query that returns last value
s last value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetFilter("Decimal Value", '<80');
        InlineQueryTestData.FindLast();
        ExpectedValue := InlineQueryTestData."Boo

        // [WHEN] Executing AsBoolean method with select LAST function in the Inline Query.
nline Query.
        ValueFromQuery := InlineQuery.AsBoolean

        // [THEN] Code Value from the AL Code and the Inline Query's return value should match
should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure MinBigIntegerValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Decimal;
        ValueFromQuery: Decimal;
        QueryText: Label 'SELECT MIN([BigInteger Value]) FROM [Inline Query Test Data] WHERE [Date Value] <= ''%1'' AND [Time Value] >= ''%2''', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value
        // [SCENARIO] Inline Query should return min value from the source table after applying filters.
        // [GIVEN] Inline Query that returns min value
ns min value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetCurrentKey("BigInteger Value");
        InlineQueryTestData.SetFilter("Date Value", '<=%1', 20200131D);
        InlineQueryTestData.SetFilter("Time Value", '>=%1', 045900T);
        InlineQueryTestData.FindFirst();
        ExpectedValue := InlineQueryTestData."BigInt

        // [WHEN] Executing AsBigInteger method with select MIN function in the Inline Query.
nline Query.
        ValueFromQuery := InlineQuery.AsBigInteger(StrSubstNo(QueryText, 20200131D

        // [THEN] BigInteger Value from the AL Code and the Inline Query's return value should match
should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure MaxDateTimeValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: DateTime;
        ValueFromQuery: DateTime;
        QueryText: Label 'SELECT MAX([DateTime Value]) FROM [Inline Query Test Data] WHERE [Decimal Value] LIKE ''40.1|50.1''', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value
        // [SCENARIO] Inline Query should return max value from the source table after applying filters.
        // [GIVEN] Inline Query that returns max value
ns max value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.SetCurrentKey("DateTime Value");
        InlineQueryTestData.SetFilter("Decimal Value", '40.1|50.1');
        InlineQueryTestData.FindLast();
        ExpectedValue := InlineQueryTestData."Date

        // [WHEN] Executing AsDateTime method with select MAX function in the Inline Query.
nline Query.
        ValueFromQuery := InlineQuery.AsDateTime

        // [THEN] DateTime Value from the AL Code and the Inline Query's return value should match
should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure AvgDecimalValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Decimal;
        ValueFromQuery: Decimal;
        QueryText: Label 'SELECT AVG([Decimal Value]) FROM [Inline Query Test Data]', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value
        // [SCENARIO] Inline Query should return avg value from the source table after applying filters.
        // [GIVEN] Inline Query that returns avg value
ns avg value
        InlineQueryTestLibrary.SetupTestData();

        InlineQueryTestData.CalcSums("Decimal Value");
        ExpectedValue := InlineQueryTestData."Decimal Value" / InlineQueryTestD

        // [WHEN] Executing AsDecimal method with select AVG function in the Inline Query.
nline Query.
        ValueFromQuery := InlineQuery.AsDecimal

        // [THEN] Decimal Value from the AL Code and the Inline Query's return value should match
should match
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

    [Test]
    procedure SumIntegerValueTest()
    var
        InlineQueryTestData: Record "Inline Query Test Data";
        ExpectedValue: Integer;
        ValueFromQuery: Integer;
        QueryText: Label 'SELECT SUM([Integer Value]) FROM [%1].[Inline Query Test Data] WHERE [Boolean Value] <> false', Locked = true;
        ValueMisMatchErr: Label 'Value should be equal to %1', Comment = '%1 = Expected Value
        // [SCENARIO] Inline Query should return sum of values from the source table after applying filters.
        // [GIVEN] Inline Query that returns sum value
ns sum value
        InlineQueryTestLibrary.SetupTestData();
        InlineQueryTestData.SetFilter("Boolean Value", '<>false');
        InlineQueryTestData.CalcSums("Integer Value");
        ExpectedValue := InlineQueryTestData."Int

        // [WHEN] Executing AsInteger method with select SUM function in the Inline Query.
nline Query.
        ValueFromQuery := InlineQuery.AsInteger(StrSubstNo(QueryText, Co

        // [THEN] Inline Query should return the expected quantity
ted quantity
        Assert.AreEqual(ExpectedValue, ValueFromQuery, StrSubstNo(ValueMisMatchErr, ExpectedValue));
    end;

}