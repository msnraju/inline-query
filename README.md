# Inline Query

Inline Query is a library that can execute SQL like Queries in Business Central AL Language. This is a small compiler in AL that compiles and executes SQL like queries in text constants or text variables. 

# Example
Count of released Sales Orders

Query

```SQL 
SELECT COUNT(1) FROM [Sales Header] WHERE Status = 'Released'
```

AL Code

```AL
procedure GetOrderCount(): Integer
var
	InlineQuery: Codeunit "Inline Query";
	OrderCount: Integer;
	QueryTxt: Label 'SELECT COUNT(1) FROM [Sales Header] WHERE Status = ''Released''', Locked = true;
begin
	OrderCount := InlineQuery.AsInteger(QueryTxt);
	exit(OrderCount);
end;
```

See [msnJournals.com](https://www.msnjournals.com/post/how-to-connect-sharepoint-with-business-central) for more information.

