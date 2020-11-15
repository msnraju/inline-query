/// <summary>
/// This codeunit allows to write and execute SQL like queries in AL Language.
/// <see cref=""/>
/// </summary>
codeunit 50104 "Inline Query"
{
    Access = Public;

    var
        InlineQueryImpl: Codeunit "Inline Query Impl";

    /// <summary>
    /// Executes the Query and returns calculated value as Integer.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <returns>Evaluated Query returns as an Integer value.</returns>
    procedure AsInteger(QueryText: Text): Integer
    begin
        exit(InlineQueryImpl.AsInteger(QueryText));
    end;

    /// <summary>
    /// Executes the Query and returns calculated value as BigInteger.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <returns>Evaluated Query returns as a BigInteger value.</returns>
    procedure AsBigInteger(QueryText: Text): BigInteger
    begin
        exit(InlineQueryImpl.AsBigInteger(QueryText));
    end;

    /// <summary>
    /// Executes the Query and returns calculated value as Code.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <returns>Evaluated Query returns as a Code value.</returns>
    procedure AsCode(QueryText: Text): Code[2048]
    begin
        exit(InlineQueryImpl.AsCode(QueryText));
    end;

    /// <summary>
    /// Executes the Query and returns calculated value as DateTime.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <returns>Evaluated Query returns as a DateTime value.</returns>
    procedure AsDateTime(QueryText: Text): DateTime
    begin
        exit(InlineQueryImpl.AsDateTime(QueryText));
    end;

    /// <summary>
    /// Executes the Query and returns calculated value as Time.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <returns>Evaluated Query returns as a Time value.</returns>
    procedure AsTime(QueryText: Text): Time
    begin
        exit(InlineQueryImpl.AsTime(QueryText));
    end;

    /// <summary>
    /// Executes the Query and returns calculated value as Boolean.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <returns>Evaluated Query returns as a Boolean value.</returns>
    procedure AsBoolean(QueryText: Text): Boolean
    begin
        exit(InlineQueryImpl.AsBoolean(QueryText));
    end;

    /// <summary>
    /// Executes the Query and returns calculated value as Date.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <returns>Evaluated Query returns as a Date value.</returns>
    procedure AsDate(QueryText: Text): Date
    begin
        exit(InlineQueryImpl.AsDate(QueryText));
    end;

    /// <summary>
    /// Executes the Query and returns calculated value as Decimal.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <returns>Evaluated Query returns as a Decimal value.</returns>
    procedure AsDecimal(QueryText: Text): Decimal
    begin
        exit(InlineQueryImpl.AsDecimal(QueryText));
    end;

    /// <summary>
    /// Executes the Query and returns calculated value as Text.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <returns>Evaluated Query returns as a Text value.</returns>
    procedure AsText(QueryText: Text): Text
    begin
        exit(InlineQueryImpl.AsText(QueryText));
    end;

    /// <summary>
    /// Executes the Query and updates ResultVariant with the calculated value.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <param name="ResultVariant">The Query result will be passed to this variable</param>
    procedure AsVariant(QueryText: Text; var ResultVariant: Variant)
    begin
        InlineQueryImpl.AsVariant(QueryText, ResultVariant);
    end;

    /// <summary>
    /// Apply Filters and Sorting to RecordRef from the Query.
    /// </summary>
    /// <param name="QueryText">The inline query text</param>
    /// <param name="RecordRef">The RecordRef variable to be updated with Sorting and Filters</param>
    procedure AsRecord(QueryText: Text; var RecordRef: RecordRef)
    begin
        InlineQueryImpl.AsRecord(QueryText, RecordRef);
    end;
}