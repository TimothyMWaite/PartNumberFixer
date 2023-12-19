page 50121 "Option Assembly List"
{
    PageType = Worksheet;
    ApplicationArea = All;
    SourceTable = "Option Assembly Line";
    Caption = 'Option Assembly List';
    Editable = true;
    MultipleNewLines = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; rec.ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID.';
                }
                field("OptionID"; rec."Option ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Option ID.';
                }
                field("LineNo"; rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Line No.';
                }
                field(No; rec.No)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the No.';
                    LookupPageId = "Item Lookup";
                    TableRelation = Item."No.";

                    trigger OnValidate()
                    var
                        iRec: Record Item;
                    begin
                        if iRec.get(rec.No) then begin
                            rec.Description := iRec.Description;
                            rec.Modify();
                        end;
                    end;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description.';
                    TableRelation = Item.Description;
                    trigger OnValidate()
                    var
                        iRec: Record Item;
                    begin
                        iRec.SetFilter(Description, rec.Description);
                        if iRec.FindFirst() then begin
                            rec.No := iRec."No.";
                            rec.Modify();
                        end;
                    end;

                }
                field(UOM; rec.UOM)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the UOM.';
                }
                field(Qty; rec.Qty)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Quantity.';
                }
                field(perConnector; rec.perConnector)
                {
                    ApplicationArea = All;
                    Caption = 'Qty Based On Connectors?';
                    ToolTip = 'Specifies if per Connector.';
                }
                field(replacePart;Rec.replacePart)
                {
                    Caption = 'Replace a Part?';
                    ApplicationArea = All;
                    
                }
                field(Replace; rec.replaceType){
                    ApplicationArea = All;
                    TableRelation = "BOM Component".catagory;
                    
                }
                // Add additional fields here if necessary
            }
        }
    }

    actions
    {
        // Define actions here if necessary
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if BelowxRec then begin

            rec.Init();
            rec."Line No." := xRec."Line No." + 1;
            rec.ID := rec.getNewID();
            rec."Option ID" := xRec."Option ID";
            rec.Designator := xRec.Designator;
            rec.Insert();
        end;
    end;

    trigger OnClosePage()
    begin
        if rec.No = '' then
            rec.Delete();
    end;

    var
        SPRec: Record "Option Suffix";
        oRec: Record Option;
}
