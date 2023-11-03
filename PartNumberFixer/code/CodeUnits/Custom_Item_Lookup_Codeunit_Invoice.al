
codeunit 50101 "Custom Item Lookup Invoice"
{
    procedure LookupItem(var SalesLineRec: Record "Sales Invoice Line"): Boolean
    var
        ItemRec: Record Item;
        LastLineRec: Record "Sales Line";
        // SalesHeaderRec: Record "Sales Header";
        Selected: Boolean;
        IsNewRecord: Boolean;
    begin
        IsNewRecord := (SalesLineRec."Line No." = 0);
        // Filter to hide "Blocked" items in the lookup
        ItemRec.SETFILTER(Blocked, 'false');
        Selected := PAGE.RunModal(PAGE::"Item List", ItemRec) = ACTION::LookupOK;
        if Selected then begin
            ItemRec.SETRANGE(PartNo, ItemRec.PartNo);
            if ItemRec.FINDFIRST then begin
                if IsNewRecord then begin
                    SalesLineRec.INIT;
                    SalesLineRec.Type := SalesLineRec.Type::Item;
                    // LastLineRec.SETRANGE("Document Type", SalesLineRec."Document Type");
                    LastLineRec.SETRANGE("Document No.", SalesLineRec."Document No.");
                    if LastLineRec.FINDLAST then begin
                        SalesLineRec."Line No." := LastLineRec."Line No." + 10000;
                    end else begin
                        SalesLineRec."Line No." := 10000;
                    end;
                end;
                // Set fields with values or default values using IF statements
                SalesLineRec."No." := ItemRec."No.";
                // Message('%1', SalesLineRec);
                SalesLineRec.Description := ItemRec.Description;
                // if SalesHeaderRec.Get(SalesLineRec."Document No.") then begin
                //     SalesLineRec."Bill-to Customer No." := SalesHeaderRec."Bill-to Customer No.";
                // end;

                if ItemRec."Base Unit of Measure" <> '' then begin
                    SalesLineRec."Unit of Measure Code" := ItemRec."Base Unit of Measure"
                end else begin
                    SalesLineRec."Unit of Measure Code" := 'PCS';
                    // Message('else %1', SalesLineRec."Unit of Measure Code");
                end;

                if ItemRec."Unit Price" <> 0 then begin

                    SalesLineRec."Unit Price" := ItemRec."Unit Price"
                end else begin
                    SalesLineRec."Unit Price" := 0;
                    // Message('else %1', SalesLineRec."Unit of Measure Code");
                end;
                if SalesLineRec."Tax Group Code" <> '' then begin
                    SalesLineRec."Tax Group Code" := ItemRec."Tax Group Code"
                end; //else begin
                     //     SalesLineRec."Tax Group Code" := 'Nontaxable';
                     //     Message('else %1', SalesLineRec."Unit of Measure Code");
                     // end;
                SalesLineRec.PartNo := ItemRec.PartNo;
                // Message('Endofall %1', SalesLineRec);
                if IsNewRecord then
                    SalesLineRec.INSERT
                else
                    SalesLineRec.MODIFY;
                exit(true);
            end else begin
                exit(false);
            end;
        end else begin
            exit(false);
        end;
    end;
}
