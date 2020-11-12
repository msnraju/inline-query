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
}