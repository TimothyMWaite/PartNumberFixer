pageextension 50106 SalesOrderSubformExt extends "Sales Order Subform"
{
    layout
    {
        addbefore("Type")
        {
            field(QuotedLeadTime; Rec.LeadTime)
            {
                ApplicationArea = All;
                Caption = 'Quoted Lead Time';
            }

            field(PartNumber; Rec.PartNumber)
            {
                ApplicationArea = All;
                Caption = 'Part Number';
                AssistEdit = false;
                ToolTip = 'This is a custom field and can be edited as needed. Any changes will not affect the default part number and will only be saved in this document. If you need to change the default part number, go to the item page and do it there.';
                DrillDown = true;
                Lookup = true;
                DrillDownPageId = OptionLineList;
                LookupPageId = "Intermediary Part List";
                TableRelation = "Intermediary Part Table";

                trigger OnAfterLookup(Selected: RecordRef)
                var
                    SalesLineRecord: Record "Sales Line";
                begin
                    // Update the line number for the sales line if necessary
                    UpdateLineNumber();
                    exit;
                end;

                trigger OnValidate()
                var
                    SalesLineUpdater: Codeunit UpdateSalesLineFields;
                    PartNumberManager: Codeunit PartNoManager;
                    SalesOrderBuffer: Record "Sales Order Entity Buffer";
                    SalesLineRecord, InvalidSalesLineRecord : Record "Sales Line";
                    OptionLineRecord: Record "OptionLine";
                    ItemRecord: Record Item;
                    BasePartNumber: Text[100];
                    PickInstructionReport: Report "Pick Instruction";
                begin
                    // If the PartNumber is empty, delete the current record and exit the trigger
                    if Rec.PartNumber = '' then begin
                        Rec.Delete();
                        exit;
                    end;

                    // Set Bill-to Customer No. if it hasn't been set yet
                    if SalesOrderBuffer.Get(Rec."Document No.") then begin
                        if (SalesOrderBuffer."Bill-to Customer No." <> '') then begin
                            if (Rec."Bill-to Customer No." = '') then begin
                                Rec.Validate("Bill-to Customer No.", SalesOrderBuffer."Bill-to Customer No.");
                                SalesOrderBuffer := SalesOrderBuffer;
                            end;
                        end;
                    end;

                    // Set a default shipment number if it hasn't been set yet
                    if Rec.ShipmentNumber = 0 then begin
                        Rec.ShipmentNumber := 1;
                    end;

                    // Update the item fields based on the selected PartNumber
                    ItemRecord.Reset();
                    ItemRecord.SetFilter(PartNumber, Rec.PartNumber);
                    if ItemRecord.FindFirst() then begin
                        Rec."No." := ItemRecord."No.";
                        Rec.Description := ItemRecord.Description;
                        Rec."Unit of Measure" := ItemRecord."Unit of Measure Id";
                        Rec."Unit Price" := ItemRecord."Unit Price";
                        Rec.Validate("No.", ItemRecord."No.");

                        // If a new item has been selected, update the record
                        if (ItemRecord.PartNumber <> OldBasePartNumber) OR (Rec."Line No." <> OldLineNumber) then begin
                            Rec.PartNumber := ItemRecord.PartNumber;
                            if not Rec.Insert(true) then begin
                                Rec.Modify(false);
                            end;
                            if ItemRecord.opts then begin
                                CurrentPartNumber := OpenPickPage();
                            end;
                        end;
                    end;

                    // Update the page with new data
                    CurrPage.Update(false);
                    OldBasePartNumber := Rec.GetItem().PartNumber;
                    OldLineNumber := Rec."Line No.";
                end;

                trigger OnDrillDown()
                var
                    SalesLineUpdater: Codeunit UpdateSalesLineFields;
                    SalesOrderBuffer: Record "Sales Order Entity Buffer";
                begin
                    // If the selected item has options, open the pick page to select an option
                    if Rec.GetItem().opts then begin
                        Rec.PartNumber := OpenPickPage();
                        CurrentPartNumber := Rec.PartNumber;
                        CurrPage.Update(false);
                    end;
                end;

                trigger OnAssistEdit()
                var
                    ItemRecord: Record Item;
                    IntermediaryPartRecord: Record "Intermediary Part Table";
                    SalesLineUpdater: Codeunit UpdateSalesLineFields;
                begin
                    // Force a page update to reflect any changes made during AssistEdit
                    CurrPage.Update;
                    exit;
                end;
            }
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                SalesLineUpdater: Codeunit UpdateSalesLineFields;
            begin
                // Update fields related to the "No." field after validation
                SalesLineUpdater.UpdateFieldsOnNoChange(Rec, xRec);
            end;
        }
        modify("Description")
        {
            trigger OnAfterValidate()
            var
                SalesLineUpdater: Codeunit UpdateSalesLineFields;
            begin
                // Update fields related to the "Description" field after validation
                SalesLineUpdater.UpdateFieldsOnDescChange(Rec, xRec);
            end;
        }
        modify("Quantity")
        {
            trigger OnAfterValidate()
            begin
                // If the selected item has a Bill of Materials (BOM), set the "Qty. to Assemble to Order"
                if Rec.GetItem().HasBOM() then begin
                    Rec."Qty. to Assemble to Order" := Rec.Quantity;
                    Rec.Modify(false);
                    Rec.Validate("Qty. to Assemble to Order");
                end;
            end;
        }
        modify("Qty. to Assemble to Order")
        {
            trigger OnBeforeValidate()
            begin
                // Placeholder for any logic that needs to occur before validation of "Qty. to Assemble to Order"
            end;

            trigger OnAfterValidate()
            var
                AssemblyLineRecord: Record "Assembly Line";
            begin
                // Update assembly information after validating "Qty. to Assemble to Order"
                UpdateAssemblyInfo();
            end;
        }
    }

    trigger OnOpenPage()
    var
        OptionLineRecord: Record OptionLine;
        OptionAssemblyLineRecord: Record "Option Assembly Line";
        AssemblyLineRecord: Record "Assembly Line";
        SalesLineRecord: Record "Sales Line";
    begin
        // Iterate through sales lines to update assembly information based on existing options
        SalesLineRecord.Reset();
        SalesLineRecord.SetFilter("Document No.", Rec."Document No.");
        if SalesLineRecord.FindSet() then begin
            repeat
                OptionLineRecord.Reset();
                OptionLineRecord.SetFilter(DocumentID, Rec."Document No.");
                OptionLineRecord.SetRange(LineNumber, SalesLineRecord."Line No.");
                if OptionLineRecord.FindSet() then begin
                    repeat
                        OptionAssemblyLineRecord.Reset();
                        OptionAssemblyLineRecord.SetRange(DesID, OptionLineRecord.SuffixID);
                        if OptionAssemblyLineRecord.FindSet() then begin
                            repeat
                                AssemblyLineRecord.Reset();
                                AssemblyLineRecord.SetFilter("Document No.", Rec."Document No.");
                                AssemblyLineRecord.SetFilter("No.", OptionAssemblyLineRecord.No);
                                if not AssemblyLineRecord.FindFirst() then begin
                                    UpdateAssemblyInfo();
                                    break;
                                end;
                            until OptionAssemblyLineRecord.Next() = 0;
                        end;
                    until OptionLineRecord.Next() = 0;
                end;
            until SalesLineRecord.Next() = 0;
        end;
    end;

    trigger OnAfterGetRecord()
    var
        OptionLineRecord: Record OptionLine;
        SalesLineRecord: Record "Sales Line";
        SalesHeaderRecord: Record "Sales Header";
    begin
        // Update option lines to reflect the current sales line data
        SalesLineRecord := Rec;
        SalesHeaderRecord := Rec.GetSalesHeader();
        OptionLineRecord.Reset();
        OptionLineRecord.SetFilter(DocumentID, SalesHeaderRecord."Quote No.");
        OptionLineRecord.SetRange(LineNumber, SalesLineRecord."Line No.");
        if OptionLineRecord.FindSet() then begin
            repeat
                OptionLineRecord.DocumentID := Rec."Document No.";
                OptionLineRecord.LineNumber := Rec."Line No.";
                OptionLineRecord.Modify(false);
            until OptionLineRecord.Next() = 0;
        end;
    end;

    procedure OpenPickPage(): Text[100]
    var
        OptionLineRecord, TempOptionLineRecord, ToPageRecord : Record OptionLine;
        ItemRecord: Record Item;
        SalesLineRecord: Record "Sales Line";
        PickPage: Page SalesLineItem;
        AssemblyManager: Codeunit AssemblyManagement;
        PartNumber: Text[200];
    begin
        // Open a modal page to pick an option and return the selected part number
        Commit();
        PickPage.SetRecord(Rec);
        PickPage.RunModal();
        exit(PickPage.GetPN());
    end;

    procedure UpdateAssemblyInfo()
    var
        OptionAssemblyLineRecord: Record "Option Assembly Line";
        AssemblyHeaderRecord, TempAssemblyHeaderRecord : Record "Assembly Header";
        OptionLineRecord: Record OptionLine;
        SalesHeaderRecord: Record "Sales Header";
        AssemblyLineRecord: Record "Assembly Line";
        ItemRecord: Record Item;
        AssembleToOrderLinkRecord: Record "Assemble-to-Order Link";
        AssemblyManager: Codeunit AssemblyManagement;
    begin
        // Update assembly header and lines based on the current sales line data
        OptionAssemblyLineRecord.Reset();
        OptionLineRecord.Reset();
        AssemblyHeaderRecord.Reset();

        AssembleToOrderLinkRecord.SetFilter("Document No.", Rec."Document No.");
        AssembleToOrderLinkRecord.SetRange("Document Line No.", Rec."Line No.");
        if AssembleToOrderLinkRecord.FindFirst() then begin
            if AssemblyHeaderRecord.Get(AssembleToOrderLinkRecord."Assembly Document Type", AssembleToOrderLinkRecord."Assembly Document No.") then begin
                TempAssemblyHeaderRecord := AssemblyHeaderRecord;
            end else begin
                TempAssemblyHeaderRecord.Init();
                TempAssemblyHeaderRecord := AssemblyManager.SetAssemblyHeaderValues(TempAssemblyHeaderRecord, Rec);
                AssembleToOrderLinkRecord.InsertAsmHeader(TempAssemblyHeaderRecord, Rec."Document Type", TempAssemblyHeaderRecord."No.");
            end;
        end else begin
            AssembleToOrderLinkRecord.Init();
            TempAssemblyHeaderRecord.Init();
            TempAssemblyHeaderRecord := AssemblyManager.SetAssemblyHeaderValues(TempAssemblyHeaderRecord, Rec);
            AssembleToOrderLinkRecord := AssemblyManager.SetAssembleToOrderValues(AssembleToOrderLinkRecord, Rec, TempAssemblyHeaderRecord);
            AssembleToOrderLinkRecord.InsertAsmHeader(TempAssemblyHeaderRecord, Rec."Document Type", TempAssemblyHeaderRecord."No.");
            AssembleToOrderLinkRecord.Insert();
        end;

        OptionLineRecord.SetFilter(DocumentID, Rec."Document No.");
        OptionLineRecord.SetRange(LineNumber, Rec."Line No.");
        if OptionLineRecord.FindSet() then begin
            repeat
                OptionAssemblyLineRecord.Reset();
                OptionAssemblyLineRecord.SetRange(DesID, OptionLineRecord.SuffixID);
                if OptionAssemblyLineRecord.FindSet() then begin
                    repeat
                        AssemblyManager.ConvertToAssemblyLine(TempAssemblyHeaderRecord, Rec, OptionAssemblyLineRecord);
                    until OptionAssemblyLineRecord.Next() = 0;
                end;
                OptionAssemblyLineRecord.Reset();
                OptionAssemblyLineRecord.SetRange(DesID, OptionLineRecord.preID);
                if OptionAssemblyLineRecord.FindSet() then begin
                    repeat
                        AssemblyManager.ConvertToAssemblyLine(TempAssemblyHeaderRecord, Rec, OptionAssemblyLineRecord);
                    until OptionAssemblyLineRecord.Next() = 0;
                end;
            until OptionLineRecord.Next() = 0;
        end;
    end;

    procedure UpdateLineNumber()
    var
        SalesLineRecord: Record "Sales Line";
    begin
        // Update the line number if it's not set yet
        if Rec."Line No." = 0 then begin
            SalesLineRecord.Reset();
            SalesLineRecord.SetRange("Document No.", Rec."Document No.");
            if SalesLineRecord.FindLast() then begin
                Rec."Line No." := SalesLineRecord."Line No." + 10000;
            end else begin
                Rec."Line No." := 10000;
                Rec."Document Type" := Rec.GetSalesHeader()."Document Type";
                Rec."Document No." := Rec.GetSalesHeader()."No.";
                Rec.Insert();
            end;
        end;
    end;

    var
        SalesOrderBuffer: Record "Sales Order Entity Buffer";
        CurrentPartNumber: Text;
        OldBasePartNumber, PreviousPartNumber : Text[100];
        OldLineNumber: Integer;
}
