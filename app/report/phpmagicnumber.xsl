<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output method="html"  encoding="UTF-8"/>
    <xsl:key name="file-category" match="//files/file" use="@path" />
    <xsl:param name="root-directory"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <title>PhpAssumptions report</title>
                <link rel="stylesheet"><xsl:attribute name="href"><xsl:value-of select="$bootstrap.min.css" /></xsl:attribute></link>
                <style>
                    .file {
                        background: #f9f9f9
                    }
                    .fixed-navbar {
                        list-style-type: none;
                        position: fixed;
                        top: 0;
                        right: 1em;
                    }
                    .suggestions.closed-suggestion ul {
                        display: none;
                    }
                    .suggestions.closed-suggestion:after {
                        content: ' [...] ';
                        cursor: pointer;
                        color: #337ab7;
                    }
                    .suggestions.closed-suggestion:hover {
                        text-decoration: underline;
                    }
                </style>
                <script>
                var onDocumentReady = [
                    function () {
                        $('[data-file]').each(function () {
                            var pathWithoutRoot = $(this).text().replace('<xsl:value-of select="$root-directory"></xsl:value-of>', '');
                            $(this).text(pathWithoutRoot);
                        });
                    }
                ];
                </script>
            </head>
            <body>

            <div class="container-fluid">
            
                <h1>PhpAssumptions report</h1>

                <nav>
                    <ul class="nav nav-pills" role="tablist">
                        <li role="presentation" class="active">
                            <a href="#overview" aria-controls="overview" role="tab" data-toggle="tab">Overview</a>
                        </li>
                        <li role="presentation">
                            <a href="#errors" aria-controls="errors" role="tab" data-toggle="tab">Errors</a>
                        </li>
                    </ul>
                </nav>

                <div class="tab-content">
                    
                    <div role="tabpanel" class="tab-pane active" id="overview">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>File</th>
                                    <th>Errors</th>
                                </tr>
                            </thead>
                            <!-- http://stackoverflow.com/a/9589085/4587679 -->
                            <xsl:for-each select="//files/file[generate-id() = generate-id(key('file-category', ./@path)[1])]">
                                <xsl:variable name="group" select="@path"/>
                                <tr>
                                    <td><strong data-file=""><xsl:value-of select="$group"/></strong></td>
                                    <td><xsl:value-of select="count(//files/file[@path = $group]/entry)"/></td>
                                </tr>
                            </xsl:for-each>
                            <tfoot>
                                <tr>
                                    <th><span class="label label-info"><xsl:value-of select="//phpmnd/@fileCount"/></span></th>
                                    <th>
                                        <span class="label label-danger"><xsl:value-of select="//phpmnd/@errorCount" /></span>
                                    </th>
                                </tr>
                            </tfoot>
                        </table>
                    </div>

                    <div role="tabpanel" class="tab-pane" id="errors">
                        <div class="fixed-navbar">
                            <div class="input-group" style="width: 20em">
                                <span class="input-group-addon"><span class="glyphicon glyphicon-search" aria-hidden="true"></span></span>
                                <input data-search="errors" type="text" class="form-control" placeholder="undefined..." />
                            </div>
                        </div>
                        <script>
                        onDocumentReady.push(function () {
                            var groups = $('[data-filterable] tbody tr[data-permanent]');
                            var rows = $('[data-filterable] tbody tr:not([data-permanent])');

                            $("[data-search]").keyup(function () {
                                var term = $(this).val().toLowerCase();

                                rows.hide();
                                groups.show();
                                matchElements(rows).show();
                                matchEmptyGroups().hide();

                                function matchElements(elements) {
                                    return elements.filter(function () {
                                        var rowContent = $(this).text().toLowerCase();
                                        return rowContent.indexOf(term) !== -1
                                    });
                                }

                                function matchEmptyGroups() {
                                    return groups.filter(function () {
                                        var group = $(this).data('permanent');
                                        return rows
                                            .filter(function () {
                                                return $(this).data('group') == group <![CDATA[&&]]> $(this).is(':visible');
                                            })
                                            .length == 0;
                                    });
                                }
                            });
                        });
                        onDocumentReady.push(function () {
                            $('.suggestions').on('click', function() {
                                $(this).toggleClass('closed-suggestion');
                            });
                        });
                        </script>

                        <table class="table" data-filterable="errors">
                            <thead>
                                <tr>
                                    <th>Error</th>
                                    <th>Line</th>
                                </tr>
                            </thead>
                            <xsl:for-each select="//files/file[generate-id() = generate-id(key('file-category', ./@path)[1])]">
                                <xsl:variable name="group" select="@path"/>
                                <tr>
                                    <xsl:attribute name="data-permanent">
                                        <xsl:value-of select="$group" />
                                    </xsl:attribute>
                                    <td colspan="3" class="file"><strong data-file=""><xsl:value-of select="$group" /></strong></td>
                                </tr>
                                <xsl:for-each select="//files/file[@path = $group]/entry">
                                    <tr>
                                        <xsl:attribute name="data-group">
                                            <xsl:value-of select="../@name" />
                                        </xsl:attribute>
                                        <td>
                                            <pre class="text-muted">
                                                <xsl:value-of select="substring(snippet/text(), 0, number(@start)+1)" />
                                                <span class="text-danger bg-danger">
                                                    <xsl:value-of select="substring(snippet/text(), number(@start)+1, number(@end) - number(@start))" />
                                                </span>
                                                <xsl:value-of select="substring(snippet/text(), number(@end)+1)" />
                                            </pre>
                                            <xsl:if test="count(suggestions/suggestion) > 0">
                                                <div class="suggestions closed-suggestion">
                                                    <strong>Suggestions</strong>
                                                    <ul>
                                                        <xsl:for-each select="suggestions/suggestion">
                                                            <li><xsl:value-of select="./text()" /></li>
                                                        </xsl:for-each>
                                                    </ul>
                                                </div>
                                            </xsl:if>
                                        </td>
                                        <td><xsl:value-of select="@line" /></td>
                                    </tr>
                                </xsl:for-each>
                            </xsl:for-each>
                        </table>
                    </div>
                </div>
            </div>


            <script><xsl:attribute name="src"><xsl:value-of select="$jquery.min.js" /></xsl:attribute></script>
            <script><xsl:attribute name="src"><xsl:value-of select="$bootstrap.min.js" /></xsl:attribute></script>
            <script>
                $(document).ready(onDocumentReady);
            </script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>