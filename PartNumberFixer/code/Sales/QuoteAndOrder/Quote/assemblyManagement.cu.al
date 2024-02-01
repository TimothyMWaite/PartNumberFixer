codeunit 50146 AssemblyManagement
{
    procedure setAssemblyHeaderValues(hRec: Record "Assembly Header"; rec: Record "Sales Line"): Record "Assembly Header"
    var
        head: Record "Assembly Header";
    begin
        head.Reset();
        hRec."Document Type" := rec."Document Type"; // Set the document type, e.g., to Order
        if head.FindLast() then begin
            hRec."No." := IncrementID(head."No.");
        end else begin
            hrec."No." := 'A00001';
        end;

        // hRec."No." := rec."Document No.";
        hRec.Description := rec.Description; // Transfer the description
        hRec."Item No." := rec."No."; // Map the Item No. from Sales Line to Assembly Header
        hRec."Variant Code" := rec."Variant Code"; // Transfer the Variant Code
        hRec."Location Code" := rec."Location Code"; // Transfer the Location Code
        hRec.Quantity := rec.Quantity; // Transfer the Quantity
        hRec."Unit of Measure Code" := rec."Unit of Measure Code"; // Transfer the Unit of Measure
        hRec."Due Date" := rec."Shipment Date"; // Map Shipment Date to Due Date
        hRec."Shortcut Dimension 1 Code" := rec."Shortcut Dimension 1 Code"; // Transfer Shortcut Dimension 1
        hRec."Shortcut Dimension 2 Code" := rec."Shortcut Dimension 2 Code"; // Transfer Shortcut Dimension 2
        exit(hRec);
    end;

    procedure IncrementID(currentID: Code[20]) ResultID: Code[20]
    var
        LetterPart: Text[1];
        NumberPart: Integer;
    begin
        // Extract the letter and number parts
        LetterPart := CopyStr(currentID, 1, 1);
        Evaluate(NumberPart, CopyStr(currentID, 2, 5));

        // Increment the number part
        NumberPart := NumberPart + 1;

        // Format the number part back to a string with leading zeros
        ResultID := LetterPart + Format(NumberPart, 0, '<FiveDigits>');
    end;

    procedure setAssemblyLineValues(
    dRec: Record "Assembly Line";
    hRec: Record "Assembly Header";
    rec: Record "Sales Line";
    aRec: Record "Option Assembly Line";
    ioRec: Record "Item Option Line"): Record "Assembly Line"
    var
        iRec: Record Item;

    begin
        dRec.Type := dRec.Type::Item;
        dRec."No." := aRec.No; // Adjusted to use 'rec' directly
        dRec.Description := rec.Description;
        dRec."Unit of Measure Code" := rec."Unit of Measure Code";
        dRec."Quantity per" := ioRec.Qty;
        dRec."Quantity" := ioRec.Qty * rec."Qty. to Asm. to Order (Base)";

        // Additional fields from Item Record (iRec), assuming iRec is defined and accessible
        if iRec.Get(aRec.No) then begin
            dRec."Unit Cost" := iRec."Unit Cost";
            dRec."Cost Amount" := dRec.Quantity * iRec."Unit Cost";
            // Message('CA:%1 QTY:%2 UC: %3', dRec."Cost Amount", dRec.Quantity, iRec."No.");
            dRec."Location Code" := rec."Location Code";
            // dRec.CheckBin(); // This would need to be adjusted if CheckBin requires context or parameters
            dRec."Inventory Posting Group" := iRec."Inventory Posting Group";
            dRec."Gen. Prod. Posting Group" := iRec."Gen. Prod. Posting Group";
            // Add more fields as available in iRec
        end else begin
            Message('Item not set correctly in option.  Please go to option list and check assembly information.');
        end;
        ;

        // Populate additional fields from Assembly Header Record (hRec) and Assemble-To-Order Link record (atoRec)
        dRec."Variant Code" := hRec."Variant Code";
        dRec."Due Date" := rec."Shipment Date";
        // Perform checks and validations

        // Update the record
        if dRec.Quantity > iRec.Inventory then begin
            dRec."Avail. Warning" := true;
        end else
            dRec."Avail. Warning" := false;

        exit(dRec);
    end;

    procedure setAtoValues(atoRec: Record "Assemble-to-Order Link";
    rec: Record "Sales Line";
    hRec: Record "Assembly Header"): Record "Assemble-to-Order Link"
    begin
        atoRec."Document No." := rec."Document No.";
        atoRec."Document Type" := rec."Document Type";
        atoRec."Document Line No." := atoRec."Document Line No.";
        atoRec."Assembly Document No." := hRec."No.";
        atoRec."Assembly Document Type" := hRec."Document Type";
        atoRec."Assembled Quantity" := rec."Qty. to Assemble to Order";
        exit(atoRec);
    end;

    procedure checkOptionRecs(lRec: Record OptionLine;
    aRec: Record "Option Assembly Line";
    dRec: Record "Assembly Line";
    hRec: Record "Assembly Header";
    rec: Record "Sales Line")
    var
        ALMgt: Codeunit "Assembly Line Management";
        ioRec: Record "Item Option Line";
    begin

        ioRec.SetFilter("ItemNo.", rec."No.");
        ioRec.SetFilter(OptionID, Format(lRec.oID));
        if ioRec.FindFirst() then begin
            if lRec.preSelection <> '' then begin
                aRec.Reset();
                aRec.SetRange("Option ID", lRec.oID);
                aRec.SetFilter(Designator, lRec.preSelection);
                if aRec.FindSet() then begin
                    repeat
                        dRec.Reset();
                        // Assuming hRec (Assembly Header), dRec (Assembly Line), and other variables are defined and accessible
                        // Insert the assembly line record
                        ALMgt.InsertAsmLine(hRec, dRec, false);
                        dRec := setAssemblyLineValues(dRec, hRec, rec, aRec, ioRec);
                        dRec.Validate(Quantity);
                        ALMgt.UpdateWarningOnLines(hRec);
                        dRec.Modify(true);
                    until aRec.Next() = 0;
                end;
            end;
            if lRec.sufSelection <> '' then begin
                aRec.Reset();
                aRec.SetRange("Option ID", lRec.oID);
                aRec.SetFilter(Designator, lRec.sufSelection);
                if aRec.FindSet() then begin
                    repeat
                        // Insert the assembly line record
                        ALMgt.InsertAsmLine(hRec, dRec, false);
                        dRec := setAssemblyLineValues(dRec, hRec, rec, aRec, ioRec);
                        dRec.Validate(Quantity);
                        dRec.Modify(true);
                    until aRec.Next() = 0;
                end;
            end;
        end else
            Message('ioRec failed, %1 %2', rec."No.", aRec."Option ID");
        ;
    end;
}