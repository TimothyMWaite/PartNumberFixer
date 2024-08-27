/**
 * This codeunit contains functions related to assembly management in the sales process.
 * It includes procedures for setting assembly header values, incrementing IDs, setting assembly line values,
 * setting assemble-to-order values, and checking option records.
 * 
 * @module AssemblyManagement
 */
codeunit 50146 AssemblyManagement
{
    procedure setAssemblyHeaderValues(hRec: Record "Assembly Header"; rec: Record "Sales Line"): Record "Assembly Header"
    var
        head: Record "Assembly Header";
        noS: Codeunit "No. Series";
    begin
        head.Reset();
        hRec."Document Type" := rec."Document Type"; // Set the document type, e.g., to Order
        if head.FindLast() then begin
            hRec."No." := noS.GetNextNo(head."No. Series");
            // hRec."No." := IncrementID(head."No.");
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

    // procedure IncrementID(currentID: Code[20]) ResultID: Code[20]
    // var
    //     LetterPart: Text[1];
    //     NumberPart: Integer;
    // begin
    //     // Extract the letter and number parts
    //     LetterPart := CopyStr(currentID, 1, 1);
    //     Evaluate(NumberPart, CopyStr(currentID, 2, 5));

    //     // Increment the number part
    //     NumberPart := NumberPart + 1;

    //     // Format the number part back to a string with leading zeros
    //     ResultID := LetterPart + NumberPart;
    // end;

    procedure setAssemblyLineValues(dRec: Record "Assembly Line"; hRec: Record "Assembly Header"; rec: Record "Sales Line"; olRec: Record "OptionLine"): Record "Assembly Line"
    var
        oRec: Record "Option";
        sRec: Record "Option Designators";
        iRec: Record Item;
    begin
        // oRec.Reset();
        // sRec.Reset();
        // iRec.Reset();
        // iRec := rec.GetItem();

        // if oRec.get(olRec.Id) then begin
        //     if olRec.sufSelection <> '' then begin
        //         if sRec.get(olRec.sufSelection) then begin

        //         end;
        //     end;
        //     //Add assembly fields for
        // end;
    end;

    procedure setAssemblyLineValues(
    dRec: Record "Assembly Line";
    hRec: Record "Assembly Header";
    rec: Record "Sales Line";
    oalRec: Record "Option Assembly Line"
    ): Record "Assembly Line"
    var
        iRec: Record Item;

    begin
        dRec.Type := dRec.Type::Item;
        dRec."No." := oalRec."No";
        dRec.Description := oalRec.Description;
        dRec."Unit of Measure Code" := rec."Unit of Measure Code";
        if oalRec."Per Port" then begin
            dRec."Quantity per" := oalRec.Qty * rec.GetItem().ports;
        end else begin
            dRec."Quantity per" := oalRec.Qty;
        end;

        dRec.Quantity := rec.Quantity * dRec."Quantity per";
        // Additional fields from Item Record (iRec), assuming iRec is defined and accessible
        if iRec.Get(oalRec.No) then begin
            dRec."Unit Cost" := iRec."Unit Cost";
            dRec."Cost Amount" := dRec.Quantity * iRec."Unit Cost";
            // // message('CA:%1 QTY:%2 UC: %3', dRec."Cost Amount", dRec.Quantity, iRec."No.");
            dRec."Location Code" := rec."Location Code";

            // dRec.CheckBin(); // This would need to be adjusted if CheckBin requires context or parameters
            dRec."Inventory Posting Group" := iRec."Inventory Posting Group";
            dRec."Gen. Prod. Posting Group" := iRec."Gen. Prod. Posting Group";
            // Add more fields as available in iRec
        end else begin
            Error('Item not set correctly in option.  Please go to option list and check assembly information.');
        end;


        // Populate additional fields from Assembly Header Record (hRec) and Assemble-To-Order Link record (atoRec)
        dRec."Variant Code" := hRec."Variant Code";
        dRec."Due Date" := rec."Shipment Date";
        // Perform checks and validations

        // Update the record
        if dRec.Quantity > iRec.Inventory then begin
            dRec."Avail. Warning" := true;
        end else
            dRec."Avail. Warning" := false;
        // message('%1', dRec);
        exit(dRec);
    end;

    procedure SetAssembleToOrderValues(atoRec: Record "Assemble-to-Order Link";
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

    // procedure checkOptionRecs(lRec: Record OptionLine;
    // hRec: Record "Assembly Header";
    // rec: Record "Sales Line")
    // var
    //     ALMgt: Codeunit "Assembly Line Management";
    //     oalRec: Record "Option Assembly Line";
    //     alRec: Record "Assembly Line";
    // begin
    //     oalRec.Reset();
    //     oalRec.SetFilter("Option ID", Format(lRec.oID));
    //     oalRec.SetRange(DesID, lRec.Id);
    //     if oalRec.FindSet() then begin
    //         repeat
    //             convertToAssLine(hRec, rec, oalRec);
    //         until oalRec.Next() = 0;
    //     end;



    //     // ioRec.SetFilter("ItemNo.", rec."No.");
    //     // ioRec.SetFilter(OptionID, Format(lRec.oID));
    //     // if ioRec.FindFirst() then begin
    //     //     if lRec.preSelection <> '' then begin
    //     //         aRec.Reset();
    //     //         aRec.SetRange("Option ID", lRec.oID);
    //     //         aRec.SetFilter(Designator, lRec.preSelection);
    //     //         if aRec.FindSet() then begin
    //     //             repeat
    //     //                 dRec.Reset();
    //     //                 // Assuming hRec (Assembly Header), dRec (Assembly Line), and other variables are defined and accessible
    //     //                 // Insert the assembly line record
    //     //                 ALMgt.InsertAsmLine(hRec, dRec, false);
    //     //                 dRec := setAssemblyLineValues(dRec, hRec, rec, aRec, ioRec);
    //     //                 dRec.Validate(Quantity);
    //     //                 ALMgt.UpdateWarningOnLines(hRec);
    //     //                 dRec.Modify(true);
    //     //             until aRec.Next() = 0;
    //     //         end;
    //     //     end;
    //     //     if lRec.sufSelection <> '' then begin
    //     //         aRec.Reset();
    //     //         aRec.SetRange("Option ID", lRec.oID);
    //     //         aRec.SetFilter(Designator, lRec.sufSelection);
    //     //         if aRec.FindSet() then begin
    //     //             repeat
    //     //                 // Insert the assembly line record
    //     //                 ALMgt.InsertAsmLine(hRec, dRec, false);
    //     //                 dRec := setAssemblyLineValues(dRec, hRec, rec, aRec, ioRec);
    //     //                 dRec.Validate(Quantity);
    //     //                 dRec.Modify(true);
    //     //             until aRec.Next() = 0;
    //     //         end;
    //     //     end;
    //     // end else
    //     //     // message('ioRec failed, %1 %2', rec."No.", aRec."Option ID");
    //     // ;
    // end;

    procedure convertToAssemblyLine(hRec: Record "Assembly Header"; rec: Record "Sales Line"; oalRec: Record "Option Assembly Line")
    var
        alrec: Record "Assembly Line";
        bCom, rR : Record "BOM Component";
        Almgt: Codeunit "Assembly Line Management";
    begin
        // // message('No: %1, Document No: %2', oalRec."No", hRec."No.");


        alrec.Reset();
        alrec.SetFilter("No.", oalRec.No);
        alrec.SetRange("Document No.", hRec."No.");
        if alrec.FindFirst() then begin
            // message('Found Assembly Line');
            alrec := setAssemblyLineValues(alrec, hRec, rec, oalRec);
            alrec.Validate("Quantity");
            alrec.checkPartNo(rec);
            alrec.Modify(true);
        end else begin
            // // message('Creating Assembly Line');
            // alrec.init();
            alrec.SetAssemblyHeader(hRec);
            Almgt.InsertAsmLine(hRec, alrec, false);
            alrec := setAssemblyLineValues(alrec, hRec, rec, oalRec);
            alrec.Validate("Quantity");
            alrec.Modify(true);
            // // message('Assembly Line Created: %1', alrec);

        end;

    end;

    procedure deleteParts(hRec: Record "Assembly Header"; oRec: Record "Option Assembly Line"; rec: Record "Sales Line"): Boolean
    var
        alRec: Record "Assembly Line";
        bomComp: Record "BOM Component";
        iRec: Record Item;
    begin
        bomComp.Reset();
        bomComp.SetFilter("Parent Item No.", rec."No.");
        if bomComp.FindSet() then begin
            iRec.reset();
            iRec.SetFilter("No.", bomComp."No.");
            if iRec.get(bomComp."No.") then begin
                if iRec."Item Type" = oRec.replacesPartType then begin
                    alRec.Reset();
                    alRec.SetFilter("No.", bomComp."No.");
                    alRec.setRange(partType, oRec.replacesPartType);
                    alRec.SetRange("Document No.", hRec."No.");

                    if alRec.FindSet() then begin
                        repeat
                            Message('Deleting Part: %1', alRec."No.");
                            alRec.Delete(true);
                        until alRec.Next() = 0;
                    end else begin
                        exit(false);
                    end;
                    exit(true);
                end;
            end;
        end;
    end;
}