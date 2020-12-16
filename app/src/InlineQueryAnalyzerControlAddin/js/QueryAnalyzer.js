const controlAddIn = document.getElementById('controlAddIn');

controlAddIn.innerHTML = `
    <div class="inline-query">
        <label>Inline Query Analyzer</label>
        <select id="resultType" class="result-type">
            <option value="0" selected>Grid</option>
            <option value="2">Json</option>
        </select>
        <div class="query-container">
            <textarea id="query" rows="4" placeholder="Write SQL like Queries here..."></textarea>
        </div>
        <div class="execute-container">
            <button id="executeQuery">Execute</button>
        </div>
        <div id="inlineQueryResult">
        </div>
    </div>
`;

document.getElementById('resultType').onchange = function () {
    updateShowGridOrJson();
}

function updateShowGridOrJson() {
    const resultTypeEl = document.getElementById('resultType');
    const resultType = resultTypeEl.value == 0 ? "grid" : "json";

    const myGridEl = document.getElementById('myGrid');
    const myJsonEl = document.getElementById('myJson');
    
    myGridEl.style.display = 'none';
    myJsonEl.style.display = 'none';

    switch (resultType) {
        case "grid":
            myGridEl.style.display = 'block';
            break;
        case "json":
            myJsonEl.style.display = 'block';
            break;
    }
}

document.getElementById('executeQuery').onclick = function () {
    const queryEl = document.getElementById('query');
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ExecuteQuery', [queryEl.value]);
}

window.UpdateError = function(query, message) {
    const html = `
        <div><pre><code class="sql">${query}</code></pre></div>
        <div id="myError"><pre><code>${message}</code></pre></div>
    `;

    const inlineQueryResult = document.getElementById('inlineQueryResult');
    inlineQueryResult.innerHTML = html;
}


window.UpdateResults = function (query, headers, data) {
    const html = `
        <div><pre><code class="sql">${query}</code></pre></div>
        <div id="myGrid" style="height: 200px; width:100%;" class="ag-theme-balham"></div>
        <div id="myJson"><pre><code class="json">${JSON.stringify(data, null, 2)}</code></pre></div>
    `;

    const inlineQueryResult = document.getElementById('inlineQueryResult');
    inlineQueryResult.innerHTML = html;

    document.querySelectorAll('pre code').forEach((block) => {
        hljs.highlightBlock(block);
    });

    const columnDefs = [];

    headers.forEach(header => {
        columnDefs.push({ headerName: header.Caption, field: header.Name, resizable: true, sortable: true });
    })

    // let the grid know which columns and what data to use
    var gridOptions = {
        columnDefs: columnDefs,
        rowData: data
    };

    // setup the grid after the page has finished loading
    var gridDiv = document.querySelector('#myGrid');
    new agGrid.Grid(gridDiv, gridOptions);
    updateShowGridOrJson();
}

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady');