pageextension 50100 ItemCardExt extends "Item Card"
{

    layout
    {
        addfirst(Item)
        {
            field(PartNo; Rec.PartNo)
            {
                ApplicationArea = All;
            }
        }

        addafter(Item)
        {
            group("Item Options")
            {
                part(ItemOptionsPart; "Option SubList")
                {

                    ApplicationArea = All;
                    Enabled = (rec."No." <> '');
                    Editable = (rec."No." <> '');
                    SubPageLink = "ItemNo." = field("No.");

                }
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
    trigger OnOpenPage()
    begin
        CurrPage.ItemOptionsPart.Page.setItem(rec);
    end;

    procedure getCurrentRec(): Record Item
    begin
        exit(rec);
    end;

}