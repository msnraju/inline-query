

controladdin QueryAnalyzerControlAddIn
{
    RequestedHeight = 300;
    MinimumHeight = 300;
    RequestedWidth = 700;
    MinimumWidth = 700;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.3.2/highlight.min.js',
        'https://unpkg.com/ag-grid-community/dist/ag-grid-community.min.js';

    StartupScript = 'js\QueryAnalyzer.js';
    StyleSheets = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.3.2/styles/tomorrow.min.css',
        'css\QueryAnalyzer.css';

    event ControlAddInReady();
    event ExecuteQuery(QueryText: Text);
    procedure UpdateResults(QueryText: Text; Headers: JsonArray; Data: JsonArray);
    procedure UpdateError(QueryText: Text; Message: Text);
}