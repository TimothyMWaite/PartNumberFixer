codeunit 50102 UpdateSalesLineFields
{
    procedure UpdateFieldsOnPartNoChange(var r: Record "Sales Line"; obPN: Text): Record "Item"
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
        UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
    begin
        ItemRec.reset();
        ItemRec.SetFilter(PartNumber, r.PartNumber);
        if ItemRec.FindFirst() then begin
        r.Validate("No.", ItemRec."No.");
            if ItemRec.PartNumber <> obPN then begin
                r.Validate(PartNumber, ItemRec.PartNumber);
            end;
        exit(ItemRec);
        end;
    end;

    procedure UpdateFieldsOnNoChange(var SalesLineRec: Record "Sales Line"; xRec: Record "Sales Line")
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
        UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
    begin
        if SalesLineRec.PartNumber = '' then begin
            if ItemRec.Get(SalesLineRec."No.") then begin
                if not (SalesLineRec.PartNumber = ItemRec.PartNumber) then begin
                    if not ((SalesLineRec.PartNumber = xRec.PartNumber) AND (xRec.PartNumber <> '')) then begin
                        SalesLineRec.PartNumber := ItemRec.PartNumber;
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
        // Message('Onvalidate called, PN: %1 No.: %2', rec.PartNumber, rec."No.");
        if rec.PartNumber = '' then begin
            if ItemRec.Get(rec."No.") then begin
                if not (rec.PartNumber = ItemRec.PartNumber) then begin
                    if not ((rec.PartNumber = xRec.PartNumber) AND (xRec.PartNumber <> '')) then begin
                        // rec.Validate("No.", ItemRec."No.");
                        rec.Validate(PartNumber, ItemRec.PartNumber);
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
        if IntermediaryPartRec.Get(SalesLineRec.PartNumber) then begin
            if not (SalesLineRec."No." = IntermediaryPartRec."Item ID") then begin
                SalesLineRec.Validate("No.", IntermediaryPartRec."Item ID");
                SalesLineRec.Validate(PartNumber, IntermediaryPartRec.PartNumber);
            end;
        end;
    end;

    procedure UpdateInvFieldsOnNoChange(var SalesLineRec: Record "Sales Invoice Line"; xRec: Record "Sales Invoice Line")
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
        UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
    begin
        if SalesLineRec.PartNumber = '' then begin
            if ItemRec.Get(SalesLineRec."No.") then begin
                if not (SalesLineRec.PartNumber = ItemRec.PartNumber) then begin
                    if not ((SalesLineRec.PartNumber = xRec.PartNumber) AND (xRec.PartNumber <> '')) then begin
                        SalesLineRec.PartNumber := ItemRec.PartNumber;
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
        // Message('Onvalidate called, PN: %1 No.: %2', rec.PartNumber, rec."No.");
        if rec.PartNumber = '' then begin
            if ItemRec.Get(rec."No.") then begin
                if not (rec.PartNumber = ItemRec.PartNumber) then begin
                    if not ((rec.PartNumber = xRec.PartNumber) AND (xRec.PartNumber <> '')) then begin
                        // rec.Validate("No.", ItemRec."No.");
                        rec.Validate(PartNumber, ItemRec.PartNumber);
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

    procedure checkOpts(fullPn: Text[200]; basePn: Text[100])
    begin

    end;

    procedure stillOldPN(var SalesLineRec: Record "Sales Line"): Boolean
    var
        iRec: Record Item;

    begin
        if iRec.Get(SalesLineRec."No.") then begin
            exit(SalesLineRec.PartNumber.Contains(iRec.PartNumber));
        end;
    end;

    // procedure checkOpts(r: Record "Sales Line")
    // var
    //     ol, prev : Record OptionLine;
    //     od: Record "Option Designators";
    //     change: text[50];
    // begin
    //     ol.Reset();
    //     ol.SetFilter(DocumentID, r."Document No.");
    //     ol.SetRange(Line, r."Line No.");
    //     if ol.FindSet() then begin
    //         repeat
    //             if not r.PartNumber.Contains(ol.preSelection) then begin
    //                 //Where I need the changed designator
    //                 if od.Get(ol.preID) then begin
    //                     //Prefix manually changed
    //                     if Dialog.Confirm('CUSTOM PART NUMBER DETECTED: Does this changing the original PartNumber to %1 alter the assembly BOM?', true, r.PartNumber) then begin
    //                         Message('Okay, then you will need to add it to the option and set the assembly changes.');
    //                         r.PartNumber := r.getPartNo();
    //                         r.Modify(false);
    //                         Page.Run(Page::OptionList);
    //                     end;
    //                 end;
    //             end;
    //             if not r.PartNumber.Contains(ol.sufSelection) then begin
    //                 //suffix manually changed

    //             end;
    //             prev := ol;
    //         until ol.Next() = 0;
    //     end;
    // end;

    procedure ExtractChangedDesignator(OriginalSelection: Text; ModifiedPartNo: Text): Text
    var
        i: Integer;
        OriginalLen: Integer;
        ModifiedLen: Integer;
        Designator: Text;
    begin
        OriginalLen := StrLen(OriginalSelection);
        ModifiedLen := StrLen(ModifiedPartNo);

        // Find the position where the strings start to differ
        for i := 1 to Min(OriginalLen, ModifiedLen) do begin
            if CopyStr(OriginalSelection, i, 1) <> CopyStr(ModifiedPartNo, i, 1) then begin
                // Extract the designator from the modified part number starting from this position
                Designator := CopyStr(ModifiedPartNo, i, ModifiedLen - i + 1);
                exit(Designator);
            end;
        end;

        // If the modified part number is longer than the original, the designator is at the end
        if ModifiedLen > OriginalLen then begin
            Designator := CopyStr(ModifiedPartNo, OriginalLen + 1, ModifiedLen - OriginalLen);
        end else begin
            // No new designator found
            Designator := '';
        end;

        exit(Designator);
    end;

    procedure Min(a: Integer; b: Integer): Integer
    begin
        if a < b then
            exit(a);
        exit(b);
    end;

    procedure deleteOldOptionLines(var SalesLineRec: Record "Sales Line")
    var
        od: Record "OptionLine";
        pnM: Codeunit PartNoManager;
    begin
        if pnM.readyForValidation(SalesLineRec) then begin

            od.Reset();
            od.SetFilter(DocumentID, SalesLineRec."Document No.");
            od.SetRange(LineNumber, SalesLineRec."Line No.");
            if od.FindSet() then begin
                od.DeleteAll();
            end;
        end;
    end;
}