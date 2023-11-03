pageextension 50108 SalesQuoteHeadExt extends "Sales Quote"
{
    layout
    {
        moveafter("Sell-to Customer Name"; "Your Reference")
        moveafter("Your Reference"; "Work Description")
        modify("Work Description")
        {
            Caption = 'Lead Time';
        }
        modify("Your Reference")
        {
            Caption = 'P.O. Number';
        }
        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            var
            begin
                rec."Quote Valid Until Date" := CalcDate('<90D>', Today());
                Rec.Modify();
                CurrPage.Update();
            end;
        }

    }
}
