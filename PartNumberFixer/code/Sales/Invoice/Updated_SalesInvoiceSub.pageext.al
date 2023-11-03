pageextension 50105 SalesInvoiceSubformExt extends "Posted Sales Invoice Subform"
{
    layout
    {
        addafter("Type")
        {
            field(PartNo; Rec.PartNo)
            {
                ApplicationArea = ALL;
                Caption = 'Part Number';
                AssistEdit = true;
                TableRelation = "Intermediary Part Table";

                trigger OnValidate()
                var
                    UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
                begin
                    UpdateSalesLineFields.UpdateInvFieldsOnPartNoChange(Rec);
                    CurrPage.Update();
                end;


                trigger OnAssistEdit()
                var
                    ItemRec: Record Item;
                    IntermediaryPartRec: Record "Intermediary Part Table";
                    UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
                begin

                    CurrPage.Update;// Force a page update
                    exit;
                end;


            }

        }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
            begin
                UpdateSalesLineFields.UpdateInvFieldsOnNoChange(Rec, xRec);
            end;
        }
        modify("Description")
        {
            trigger OnAfterValidate()
            var
                UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
            begin
                UpdateSalesLineFields.UpdateInvFieldsOnDescChange(Rec, xRec);
            end;
        }


    }
}