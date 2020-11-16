table 50100 "Inline Query Test Data"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Boolean Value"; Boolean)
        {
        }
        field(3; "Time Value"; Time)
        {
        }
        field(4; "Date Value"; Date)
        {
        }
        field(5; "DateTime Value"; DateTime)
        {
        }
        field(6; "Integer Value"; Integer)
        {
        }
        field(7; "BigInteger Value"; BigInteger)
        {
        }
        field(8; "Decimal Value"; Decimal)
        {
        }
        field(9; "Code Value"; Code[20])
        {
        }
        field(10; "Text Value"; Text[100])
        {
        }
        field(11; "Guid Value"; Guid)
        {
        }
        field(12; "Duration Value"; Duration)
        {
        }
        field(13; "RecordId Value"; RecordId)
        {
        }
        field(14; "Option Value"; Option)
        {
            OptionMembers = " ","One","Two","Three";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}