pageextension 50100 ItemCardExt extends "Item Card"
{

    layout
    {
        addfirst(Item)
        {
            field(PartNumber; Rec.PartNumber)
            {
                ApplicationArea = All;
            }
            field(Ports; Rec.ports)
            {
                ApplicationArea = All;
            }
            field(Opts; Rec.opts)
            {
                Caption = 'Uses Options?';
                ApplicationArea = All;
            }
            field("Item Type"; Rec."Item Type")
            {
                ApplicationArea = All;
                Enabled = rec.opts;
            }
            field("PartType"; Rec."PartType")
            {
                ApplicationArea = All;
                Caption = 'Part Type';
                ToolTip = 'This is used to replace parts via options.  Meaning that if this part can be replaced by an option then this needs to be set to the same thing as the part type in the option assembly';
                trigger OnValidate()
                var
                    bom: Record "BOM Component";
                begin
                    bom.reset();
                    bom.SetFilter("No.", rec."No.");
                    if bom.FindSet() then begin
                        repeat
                            bom."PartType" := rec."PartType";
                            bom.Modify();
                        until bom.Next() = 0;
                    end;
                end;
            }
            field(showOnDocument; Rec.showOnDocument)
            {
                ApplicationArea = All;
                Caption = 'Show On Assembly Line in Sales Document';
                ToolTip = 'If this is checked, the item will show when the assembly is shown.  This is useful for things like re-radiating kits as it would help to show the parts in the kit to the customer.';

                trigger OnValidate()
                var
                    aRec: Record "Assembly Line";
                begin
                    aRec.reset();
                    aRec.SetFilter("No.", rec."No.");
                    if aRec.FindSet() then begin
                        repeat
                            aRec.showOnDocument := rec.showOnDocument;
                            aRec.Modify(true);
                        until aRec.Next() = 0;
                    end;
                end;
            }
            field(nestedOpts; Rec.nestedOpts)
            {
                ApplicationArea = All;
                Caption = 'Apply Options to Assembly Parts?';
                ToolTip = 'If checked, options will be applied to assembly parts.  Make sure to include the default part in the assembly BOM as this will just check for parts with options and apply the same options to the assembly part number.';
            }
        }

    }

    // trigger OnOpenPage()
    // var
    //     ItemOptionsPart: Page "Option SubList";
    // begin

    //     // CurrPage.ItemOptionsPart.Page.setItemNum(rec);
    // end;

    // trigger OnNewRecord(BelowxRec: Boolean)
    // var
    //     IO: Codeunit ItemOptions;
    // begin
    //     if rec."No." <> '' then
    //         IO.setItemRecord(rec);
    // end;


    procedure getCurrentRec(): Record Item
    begin
        exit(rec);
    end;

}