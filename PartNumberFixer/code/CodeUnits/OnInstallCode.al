codeunit 50103 "My Install Codeunit"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        PopulateIntermediaryTable();
        InsertTestData();
    end;

    procedure PopulateIntermediaryTable()
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
    begin

        // Loop through all items and add to intermediary table
        if ItemRec.FindSet then
            repeat
                if not IntermediaryPartRec.Get(ItemRec."PartNo") then begin
                    IntermediaryPartRec.Init();
                    if ItemRec.PartNo = '' then begin

                        ItemRec.PartNo := ItemRec."No.";
                        ItemRec.Modify();
                    end;
                    IntermediaryPartRec."PartNo" := ItemRec."PartNo";
                    IntermediaryPartRec."Item ID" := ItemRec."No.";
                    IntermediaryPartRec."Item Description" := ItemRec."Description";
                    // Populate additional fields here, if any
                    IntermediaryPartRec.Insert();
                end;
            until ItemRec.Next = 0;
        IntermediaryPartRec.SETCURRENTKEY("PartNo");
        IntermediaryPartRec.ASCENDING(TRUE);
    end;

    procedure InsertTestData()
    var
        OptionRec: Record "Option";
        sl: Record SPList;
        OptionSuffixRec: Record "Option Suffix";
        desc: InStream;
        d: Text;
        i, j : Integer;
    begin
        // Insert test data into Option table
        for i := 1 to 5 do begin
            OptionRec.Init();
            OptionRec.Id := i + 1000;
            OptionRec.Name := 'T' + Format(i);
            OptionRec.Description := 'This is a test of the description field for ' + OptionRec.Name;
            OptionRec.Caption := 'Caption ' + Format(i);
            OptionRec."Prefix Designator" := 'P' + format(i);
            OptionRec."Prefix Order" := i * 100;
            OptionRec."Price Change" := i * 10.5;
            OptionRec."Suffix Order" := i * 123;
            // OptionRec.Required := i mod 2 = 0;
            if OptionRec.Insert(false) then begin
                addSPlist(sl, OptionRec);
            end;
            for j := 1 to 5 do begin
                OptionSuffixRec.Init();
                OptionSuffixRec."Suffix Designator" := 'S' + Format(j) + Format(i);
                OptionSuffixRec."Suffix Order" := j * 100;
                OptionSuffixRec.OptionID := OptionRec.Id; // this should match an Id in Option table
                OptionSuffixRec.Line := j * 2;
                OptionSuffixRec.show := false;
                if OptionSuffixRec.Insert(false) then begin
                    addSPlist(sl, OptionSuffixRec, OptionRec."Suffix Order");
                end;
            end;
        end;

        // Insert test data into Option Suffix table
    end;

    procedure addSPlist(var SPRec: Record SPList; OptionRec: Record Option)
    begin
        // Assuming we are handling a prefix

        if not SPRec.get(Format(OptionRec.id) + OptionRec."Prefix Designator") then begin
            SPRec.Init();
            SPRec.ID := format(OptionRec.Id) + OptionRec."Prefix Designator"; // This should be a unique value, consider using a number series here
            SPRec.OptionID := OptionRec.Id;
            SPRec.Prefix := true;
            SPRec.Order := OptionRec."Prefix Order";
            SPRec.Designator := OptionRec."Prefix Designator";
            // Set other fields as necessary
            SPRec.Insert();
        end;
    end;

    procedure addSPlist(var SPRec: Record SPList; OptionSuffixRec: Record "Option Suffix"; SO: Integer)
    begin
        // Handling a suffix

        if not SPRec.get(Format(OptionSuffixRec.OptionID) + OptionSuffixRec."Suffix Designator") then begin
            // Update fields if necessary

            SPRec.Init();
            SPRec.ID := Format(OptionSuffixRec.OptionID) + OptionSuffixRec."Suffix Designator"; // This should be a unique value, consider using a number series here
            SPRec.OptionID := OptionSuffixRec.OptionID;
            SPRec.Prefix := false;
            SPRec.Order := SO;
            SPRec.Designator := OptionSuffixRec."Suffix Designator";
            // Set other fields as necessary
            SPRec.Insert();
        end;
    end;


}
