<cfinclude template="/includes/_header.cfm">
<cflayout name="outerlayout" type="vbox">
    <cflayoutarea style="height:400;">
        <cflayout name="thelayout" type="border">
            <!--- The 100% height style ensures that the background color fills 
                the area. --->
            <cflayoutarea position="top" size="100" splitter="true" 
                    style="background-color:##00FFFF; height:100%">
                This is text in layout area 1: top
            </cflayoutarea>
            <cflayoutarea title="Left layout area" position="left"
                    closable="true" 
                    collapsible="true" name="left" splitter="true"
                    style="background-color:##FF00FF; height:100%">
                This is text in layout area 2: left<br />
                You can close and collapse this area.
            </cflayoutarea>
            <cflayoutarea position="center"
                    style="background-color:##FFFF00; height:100%">
                This is text in layout area 3: center<br />
            </cflayoutarea>
            <cflayoutarea position="right" collapsible="true" 
                    title="Right Layout Area" initcollapsed="true"
                    style="background-color:##FF00FF; height:100%" >
                This is text in layout area 4: right<br />
                You can collapse this, but not close it.<br />
                It is initially collapsed.
            </cflayoutarea>
            <cflayoutarea position="bottom" size="100" splitter="true"
                     style="background-color:##00FFFF; height:100%">
                This is text in layout area 5: bottom
            </cflayoutarea> 
        </cflayout>
    </cflayoutarea>

    <cflayoutarea style="height:100; ; background-color:##FFCCFF">
        <h3>Change the state of Area 2</h3>
        <cfform>
            <cfinput name="expand2" width="100" value="Expand Area 2" type="button" 
                onClick="ColdFusion.Layout.expandArea('thelayout', 'left');">
            <cfinput name="collapse2" width="100" value="Collapse Area 2" type="button"
                onClick="ColdFusion.Layout.collapseArea('thelayout', 'left');">
            <cfinput name="show2" width="100" value="Show Area 2" type="button" 
                onClick="ColdFusion.Layout.showArea('thelayout', 'left');">
            <cfinput name="hide2" width="100" value="Hide Area 2" type="button" 
                onClick="ColdFusion.Layout.hideArea('thelayout', 'left');">
        </cfform>
    </cflayoutarea>
</cflayout>

