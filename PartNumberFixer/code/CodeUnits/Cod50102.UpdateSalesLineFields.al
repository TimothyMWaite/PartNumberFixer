codeunit 50102 UpdateSalesLineFields
{
    procedure UpdateFieldsOnPartNoChange(var SalesLineRec: Record "Sales Line")
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
        UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
    begin
        if IntermediaryPartRec.Get(SalesLineRec.PartNo) then begin
            if not (SalesLineRec."No." = IntermediaryPartRec."Item ID") then begin
                SalesLineRec.Validate("No.", IntermediaryPartRec."Item ID");
                SalesLineRec.Validate(PartNo, IntermediaryPartRec.PartNo);
            end;
        end;
    end;

    procedure UpdateFieldsOnNoChange(var SalesLineRec: Record "Sales Line"; xRec: Record "Sales Line")
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
        UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
    begin
        if SalesLineRec.PartNo = '' then begin
            if ItemRec.Get(SalesLineRec."No.") then begin
                if not (SalesLineRec.PartNo = ItemRec.PartNo) then begin
                    if not ((SalesLineRec.PartNo = xRec.PartNo) AND (xRec.PartNo <> '')) then begin
                        SalesLineRec.PartNo := ItemRec.PartNo;
                        SalesLineRec.Modify();
                    end;
                end;
            end;
        end;
    end;

    procedure UpdateFieldsOnDescChange(var rec: Record "Sales Line"; xRec: Record "Sales Line")
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
        UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
    begin
        // Message('Onvalidate called, PN: %1 No.: %2', rec.PartNo, rec."No.");
        if rec.PartNo = '' then begin
            if ItemRec.Get(rec."No.") then begin
                if not (rec.PartNo = ItemRec.PartNo) then begin
                    if not ((rec.PartNo = xRec.PartNo) AND (xRec.PartNo <> '')) then begin
                        // rec.Validate("No.", ItemRec."No.");
                        rec.Validate(PartNo, ItemRec.PartNo);
                    end else begin
                        // Message('Check4');
                    end;
                end else begin
                    // Message('Check3');
                end;
            end else begin
                // Message('Check2');
            end;
        end else begin
            // Message('Check1');
        end;

    end;

    procedure UpdateInvFieldsOnPartNoChange(var SalesLineRec: Record "Sales Invoice Line")
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
        UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
    begin
        if IntermediaryPartRec.Get(SalesLineRec.PartNo) then begin
            if not (SalesLineRec."No." = IntermediaryPartRec."Item ID") then begin
                SalesLineRec.Validate("No.", IntermediaryPartRec."Item ID");
                SalesLineRec.Validate(PartNo, IntermediaryPartRec.PartNo);
            end;
        end;
    end;

    procedure UpdateInvFieldsOnNoChange(var SalesLineRec: Record "Sales Invoice Line"; xRec: Record "Sales Invoice Line")
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
        UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
    begin
        if SalesLineRec.PartNo = '' then begin
            if ItemRec.Get(SalesLineRec."No.") then begin
                if not (SalesLineRec.PartNo = ItemRec.PartNo) then begin
                    if not ((SalesLineRec.PartNo = xRec.PartNo) AND (xRec.PartNo <> '')) then begin
                        SalesLineRec.PartNo := ItemRec.PartNo;
                        SalesLineRec.Modify();
                    end;
                end;
            end;
        end;
    end;

    procedure UpdateInvFieldsOnDescChange(var rec: Record "Sales Invoice Line"; xRec: Record "Sales Invoice Line")
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
        UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
    begin
        // Message('Onvalidate called, PN: %1 No.: %2', rec.PartNo, rec."No.");
        if rec.PartNo = '' then begin
            if ItemRec.Get(rec."No.") then begin
                if not (rec.PartNo = ItemRec.PartNo) then begin
                    if not ((rec.PartNo = xRec.PartNo) AND (xRec.PartNo <> '')) then begin
                        // rec.Validate("No.", ItemRec."No.");
                        rec.Validate(PartNo, ItemRec.PartNo);
                    end else begin
                        // Message('Check4');
                    end;
                end else begin
                    // Message('Check3');
                end;
            end else begin
                // Message('Check2');
            end;
        end else begin
            // Message('Check1');
        end;

    end;
}