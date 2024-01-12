pageextension 50103 SalesQuoteSubformExt extends "Sales Quote Subform"
{
    layout
    {
        addbefore("Type")
        {
            field(lineNo; rec."Line No.")
            {
                ApplicationArea = all;
            }
            field(PartNo; Rec.PartNo)
            {
                ApplicationArea = ALL;
                Caption = 'Part Number';
                AssistEdit = false;

                DrillDown = true;
                Lookup = true;
                DrillDownPageId = OptionLineList;
                LookupPageId = "Intermediary Part List";
                TableRelation = "Intermediary Part Table";
                trigger OnValidate()
                var
                    UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
                    sHead: Record "Sales Order Entity Buffer";
                    ioRec: Record "Item Option Line";
                    slRec, badRec : Record "Sales Line";
                begin
                    Message('%1', rec.PartNo);
                    UpdateSalesLineFields.UpdateFieldsOnPartNoChange(Rec);
                    if sHead.Get(rec."Document No.") then begin
                        if (sHead."Bill-to Customer No." <> '') then begin
                            if (rec."Bill-to Customer No." = '') then begin
                                rec.Validate("Bill-to Customer No.", sHead."Bill-to Customer No.");
                                hRec := sHead;
                            end;
                        end;
                    end;

                    if rec."Line No." <> 0 then begin
                        rec.Modify(true);
                    end else begin
                        slRec.Reset();
                        slRec.SetRange("Document No.", rec."Document No.");
                        if slRec.FindLast() then begin
                            Message('r: %1 sl: %2', rec."Line No.", slRec."Line No.");
                            rec."Line No." := slRec."Line No." + 10000;
                        end else begin
                            rec."Line No." := 10000;
                        end;
                        ioRec.Reset();
                        ioRec.SetFilter("ItemNo.", rec."No.");
                        if rec.Insert(ioRec.FindFirst()) then begin
                            ioRec.Reset();
                            ioRec.SetFilter("ItemNo.", rec."No.");
                            if ioRec.FindFirst() then begin
                                openPickPage();
                            end;
                        end;
                    end;


                    CurrPage.Update(false);
                end;

                // UpdateSalesLineFields.UpdateFields(Rec, xRec, ((xRec."No." = '') and (xRec.PartNo = '')));

                trigger OnDrillDown()
                var
                    UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
                    sHead: Record "Sales Order Entity Buffer";
                    ioRec: Record "Item Option Line";
                begin
                    ioRec.Reset();
                    ioRec.SetFilter("ItemNo.", rec."No.");
                    if ioRec.FindFirst() then begin
                        openPickPage();
                    end;

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
                UpdateSalesLineFields.UpdateFieldsOnNoChange(Rec, xRec);
            end;
        }
        modify("Description")
        {
            trigger OnAfterValidate()
            var
                UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
            begin
                UpdateSalesLineFields.UpdateFieldsOnDescChange(Rec, xRec);
            end;
        }
        modify("Qty. to Assemble to Order")
        {
            trigger OnBeforeValidate()

            begin


            end;

            trigger OnAfterValidate()
            var
                dR2: Record "Assembly Line";
            begin
                // dR2.SetFilter("Document Type", Format(Rec."Document Type"));
                // dR2.SetFilter("Document No.", Format(Rec."Document No."));
                // dR2.SetFilter("Line No.", Format(Rec."Line No."));
                if dR2.FindSet() then begin
                    repeat
                        Message('docNO: %1 /No: %2 /From: %3 /To: %4', dR2."Document No.", dR2."No.", dR2."Appl.-from Item Entry", dR2."Appl.-to Item Entry");
                    until dR2.Next() = 0;
                end;


                updateAssemblyInfo();

            end;
        }


    }
    actions
    {
        addafter(Page)
        {
            group(DOIT)
            {
                action(DOTHETHING)
                {
                    Visible = true;
                    ApplicationArea = All;
                    Caption = 'DO THE THING';
                    trigger OnAction()
                    var
                        dR2: Record "Assembly Line";
                    begin
                        // dRec.SetFilter("Document No.", rec."Document No.");
                        // dRec.SetRange("Line No.", rec."Line No.");

                        if dR2.FindSet() then begin
                            repeat
                                Message('docNO: %1 /No: %2 /From: %3 /To: %4', dR2."Document No.", dR2."No.");
                                if CopyStr(dR2."Document No.", 1, 1) = 'S' then begin
                                    dR2.Delete();
                                end;
                            until dR2.Next() = 0;
                        end;
                    end;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ioRec: Record "Item Option Line";
    begin
        if ((rec."Line No." / 5000) mod 2) = 1 then
            exit(false);
        Message('%1', rec."Line No.");
        ioRec.Reset();
        ioRec.SetFilter("ItemNo.", rec."No.");
        if ioRec.FindFirst() then begin
            openPickPage();
        end;
    end;

    trigger OnAfterGetRecord()
    var
        ioRec: Record "Item Option Line";
        olRec: Record "OptionLine";
        iRec: Record item;
        p, s : Text[50];

    begin
        p := '';
        s := '';

        ioRec.Reset();
        ioRec.SetFilter("ItemNo.", rec."No.");
        if ioRec.FindSet() then begin
            olRec.Reset();
            olRec.SetFilter(docID, rec."Document No.");
            olRec.SetRange(line, rec."Line No.");
            olRec.SetCurrentKey(sufOrder, preOrder);
            olRec.SetAscending(sufOrder, true);
            olRec.SetAscending(preOrder, true);
            if olRec.FindSet() then begin
                s += olRec.sufSelection;
                p += olRec.preSelection;
            end;

        end;
        if iRec.get(rec."No.") then begin
            rec.PartNo := p + iRec.PartNo + s;
        end;
        CurrPage.Update(false);
    end;

    // trigger OnModifyRecord(): Boolean
    // var
    //     ioRec: Record "Item Option Line";

    // begin
    //     ioRec.Reset();
    //     ioRec.SetFilter("ItemNo.", rec."No.");
    //     if ioRec.FindFirst() then begin
    //         openPickPage();
    //     end;
    // end;



    local procedure CreateDisplayText(FieldName: Text; Value1: Text; Value2: Text): Text
    begin
        exit(StrSubstNo('%1 -> Record1: %2, Record2: %3', FieldName, Value1, Value2));
    end;

    procedure openPickPage(): Text[100]
    var
        lRec, ol, fpg : Record OptionLine;
        sRec: Record SPList;
        iRec: Record Item;
        ioRec: Record "Item Option Line";
        slRec: Record "Sales Line";
        opPage: Page OptionLineList;
        pn: Text[200];
    begin
        // Message('lN: %1', rec."Line No.");
        ioRec.Reset();
        ioRec.SetFilter("ItemNo.", rec."No.");
        ol.Reset();
        ol.SetFilter(docID, rec."Document No.");
        // ol.SetRange(iID, rec."No.");
        ol.SetRange(line, rec."Line No.");
        if not ol.FindSet() then begin
            if ioRec.FindSet() then begin
                repeat
                    lRec.Reset();
                    lRec.Init();
                    lRec.docID := rec."Document No.";
                    lRec.Id := lRec.getNewID();
                    lRec.iID := ioRec."ItemNo.";
                    lRec.oID := ioRec.OptionID;
                    lRec.pre := ioRec.pre;
                    lRec.oName := ioRec.OptionName;
                    lRec.pn := rec.PartNo;
                    lRec.line := rec."Line No.";
                    lRec.Insert();
                // Message('lrLN: %1', lRec.line);
                until ioRec.Next() = 0;
            end;
        end;
        lRec.Reset();
        // lRec.SetRange(iID, rec."No.");

        opPage.SetTableView(ol);
        // Message('Filters: %1', ol.GetFilters);
        opPage.setI(rec);
        Commit();
        if opPage.RunModal() = Action::OK then begin



            CurrPage.Update(false);
            // Clear(opPage);
        end;

    end;

    procedure addAssLine()
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        ALMgt: Codeunit "Assembly Line Management";
        ahu: Codeunit "Assembly Header-Reserve";
    begin
        // Initialize or retrieve your AssemblyHeader record
        // ...

        // Insert a new line for the Assembly Header
        ALMgt.InsertAsmLine(AssemblyHeader, AssemblyLine, false);

        // Set the details of the new assembly line
        // AssemblyLine.Validate("No.", YourItemNo); // Replace YourItemNo with the actual item number
        // AssemblyLine.Validate(Quantity, YourQuantity); // Replace YourQuantity with the actual quantity
        // Set other fields as needed
        // ...

        // Insert the assembly line record into the database
        AssemblyLine.Insert();
    end;

    procedure updateAssemblyInfo()
    var
        aRec: Record "Option Assembly Line";
        hRec, head : Record "Assembly Header";
        lRec: Record OptionLine;
        dRec, c, dRec2 : Record "Assembly Line";
        ALMgt: Codeunit "Assembly Line Management";
        iRec: Record Item;
        bStr: Text[1];
        iNo: Code[20];
        p: Page "Assemble-to-Order Lines";
    begin
        bStr := '';
        aRec.Reset();
        lRec.Reset();
        head.Reset();
        if head.get(rec."Document Type", rec."Document No.") then begin
            hRec := head;
        end else begin
            hRec.Init(); // Initialize the Assembly Header record
            hRec."Document Type" := rec."Document Type"; // Set the document type, e.g., to Order
            hRec."No." := rec."Document No."; // Map the Sales Line Document No. to the Assembly Header No.
            hRec.Description := rec.Description; // Transfer the description
            hRec."Item No." := rec."No."; // Map the Item No. from Sales Line to Assembly Header
            hRec."Variant Code" := rec."Variant Code"; // Transfer the Variant Code
            hRec."Location Code" := rec."Location Code"; // Transfer the Location Code
            hRec.Quantity := rec.Quantity; // Transfer the Quantity
            hRec."Unit of Measure Code" := rec."Unit of Measure Code"; // Transfer the Unit of Measure
            hRec."Due Date" := rec."Shipment Date"; // Map Shipment Date to Due Date
            hRec."Shortcut Dimension 1 Code" := rec."Shortcut Dimension 1 Code"; // Transfer Shortcut Dimension 1
            hRec."Shortcut Dimension 2 Code" := rec."Shortcut Dimension 2 Code"; // Transfer Shortcut Dimension 2
            hRec.Insert();
        end;
        lRec.SetFilter(docID, rec."Document No.");
        lRec.SetRange(line, rec."Line No.");
        if lRec.FindSet() then begin
            repeat
                if lRec.preSelection <> '' then begin
                    aRec.Reset();
                    aRec.SetRange("Option ID", lRec.oID);
                    aRec.SetFilter(Designator, lRec.preSelection);
                    if aRec.FindSet() then begin
                        repeat
                            dRec.Reset();

                            ALMgt.InsertAsmLine(hRec, dRec, false);
                            dRec.Type := dRec.Type::Item;
                            dRec."No." := aRec.No;
                            dRec.Description := aRec.Description;
                            dRec."Unit of Measure Code" := aRec.UOM;
                            dRec."Quantity per" := aRec.Qty;
                            dRec."Quantity (Base)" := aRec.Qty * rec.Quantity;
                            if iRec.get(aRec.No) then begin
                                dRec."Cost Amount" := iRec."Unit Cost" * dRec.Quantity;
                                iNo := iRec."No.";
                            end;
                            dRec.Modify(true);
                        // if dRec.Insert() then begin
                        //     d := dRec;


                        // end else begin
                        //     Message('Failed');
                        // end;
                        until aRec.Next() = 0;
                    end;
                end;
                if lRec.sufSelection <> '' then begin
                    aRec.Reset();
                    aRec.SetRange("Option ID", lRec.oID);
                    aRec.SetFilter(Designator, lRec.sufSelection);
                    if aRec.FindSet() then begin
                        repeat
                            Message('activated for %1', aRec.Designator);
                            dRec.Reset();
                            ALMgt.InsertAsmLine(hRec, dRec, false);
                            dRec.Type := dRec.Type::Item;
                            dRec."No." := aRec.No;
                            dRec.Description := aRec.Description;
                            dRec."Unit of Measure Code" := aRec.UOM;
                            dRec."Quantity per" := aRec.Qty;
                            dRec."Quantity (Base)" := aRec.Qty * rec.Quantity;
                            if iRec.get(aRec.No) then begin
                                dRec."Cost Amount" := iRec."Unit Cost" * dRec.Quantity;
                                iNo := iRec."No.";
                            end;
                            dRec.Modify(true);
                        // if dRec.Insert() then begin
                        //     d := dRec;
                        // end else begin
                        //     Message('Failed');
                        // end;

                        until aRec.Next() = 0;
                    end;
                end;
            // Message('%1', dRec);
            until lRec.Next() = 0;
        end;

    end;



    procedure getPNwOpts()
    var
        lRec: Record OptionLine;
    begin
        // lRec.SetFilter(docID, rec."Document No.");
        // lRec.SetRange(line, rec."Line No.");
        // lRec.SetRange(iID, rec."No.");
        // if lRec.FindFirst() then begin
        //     rec.PartNo := lRec.pn;
        //     Message('%1', rec.PartNo);
        // end;
    end;

    var
        opPage: Page OptionLineList;
        oCU: Codeunit "OP Page Manager";
        hRec: Record "Sales Order Entity Buffer";
        p: Page "Assemble-to-Order Lines";
        d: Record "Assembly Line";
        d2: Record "Assembly Header";

}