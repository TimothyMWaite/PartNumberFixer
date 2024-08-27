
codeunit 50100 "Custom Item Lookup"
{

    procedure LookupItem(var SalesLineRec: Record "Sales Line"): Boolean
    var
        PartsRec: Record "Intermediary Part Table";
        ItemRec: Record Item;
        LastLineRec: Record "Sales Line";
        Selected: Boolean;
        IsNewRecord: Boolean;
    begin
        IsNewRecord := (SalesLineRec."Line No." = 0);
        Message('inProcedure');
        // Open the lookup page for the Parts table
        Selected := PAGE.RunModal(PAGE::"Intermediary Part List", PartsRec) = ACTION::LookupOK;

        if Selected then begin
            Message('inSelected');

            // Fetch the corresponding Item record using the Item ID from the Parts table
            if ItemRec.Get(PartsRec."Item ID") then begin
                if IsNewRecord then begin
                    SalesLineRec.INIT;
                    SalesLineRec.Type := SalesLineRec.Type::Item;
                    LastLineRec.SETRANGE("Document Type", SalesLineRec."Document Type");
                    LastLineRec.SETRANGE("Document No.", SalesLineRec."Document No.");
                    if LastLineRec.FINDLAST then begin
                        SalesLineRec."Line No." := LastLineRec."Line No." + 10000;
                    end else begin
                        SalesLineRec."Line No." := 10000;
                    end;
                end;
                // Check if the item is blocked
                if ItemRec.Blocked then begin
                    Error('This item is blocked.');
                    exit(false);
                end;

                // Populate the SalesLineRec using fields from the Item record
                SalesLineRec."No." := ItemRec."No.";
                SalesLineRec.Description := ItemRec.Description;
                SalesLineRec."Unit of Measure Code" := ItemRec."Base Unit of Measure";
                SalesLineRec."Unit Price" := ItemRec."Unit Price";
                SalesLineRec."Tax Group Code" := ItemRec."Tax Group Code";
                SalesLineRec.PartNumber := PartsRec.PartNumber;

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

    procedure SetPNInvoice(var SalesInvoiceLine: Record "Sales Invoice Line"): Boolean
    var
        PartNumber: Text[100];

    begin
        // Check if PartNumber is already set
        if SalesInvoiceLine.PartNumber <> '' then
            exit;

        // Logic to fetch and set the PartNumber, assuming you have a function GetPartNoByItem()
        // that takes an Item ID and returns the corresponding PartNumber


        PartNumber := GetPartNoByItem(SalesInvoiceLine."No.");
        if PartNumber <> '' then begin
            SalesInvoiceLine.PartNumber := PartNumber;
            // SalesInvoiceLine.Modify();
            exit(true);
        end else begin
            exit(false);
        end;
        ;
    end;

    // Dummy function to fetch PartNumber by Item No., replace with your actual logic
    local procedure GetPartNoByItem(ItemNo: Code[20]): Text[100]
    var
        IntermediaryPartTableRec: Record "Intermediary Part Table";
        ItemTableRec: Record Item;
        result: Text[100];
    begin
        // Option 1: Fetch from Intermediary Part Table using FindFirst
        IntermediaryPartTableRec.SetFilter("Item ID", ItemNo);
        if IntermediaryPartTableRec.FindFirst() then begin
            result := IntermediaryPartTableRec.PartNumber;
        end else begin
            // Option 2: Fetch from Item Table
            if ItemTableRec.Get(ItemNo) then begin
                result := ItemTableRec.PartNumber;
            end else begin
                result := '';  // or some default value or error handling
                Error('Part Number could not be retrieved.  Make sure that the part number is included in the Item Card for item: %1.', ItemNo);
            end;
        end;

        exit(result);
    end;



}
