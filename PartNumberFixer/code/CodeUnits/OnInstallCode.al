codeunit 50103 "My Install Codeunit"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        PopulateIntermediaryTable();
        // InsertTestData();
        assTest();
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
        addCCtoAssembly();
        IntermediaryPartRec.SETCURRENTKEY("PartNo");
        IntermediaryPartRec.ASCENDING(TRUE);
    end;

    // procedure InsertTestData()
    // var
    //     OptionRec: Record "Option";
    //     sl: Record SPList;
    //     OptionSuffixRec: Record "Option Suffix";
    //     desc: InStream;
    //     d: Text;
    //     i, j : Integer;
    // begin
    //     // Insert test data into Option table
    //     for i := 1 to 5 do begin
    //         OptionRec.Init();
    //         OptionRec.Id := i + 1000;
    //         OptionRec.Name := 'T' + Format(i);
    //         OptionRec.Description := 'This is a test of the description field for ' + OptionRec.Name;
    //         OptionRec.Caption := 'Caption ' + Format(i);
    //         OptionRec."Prefix Designator" := 'P' + format(i);
    //         OptionRec."Prefix Order" := i * 100;
    //         OptionRec."Price Change" := i * 10.5;
    //         OptionRec."Suffix Order" := i * 123;
    //         // OptionRec.Required := i mod 2 = 0;
    //         OptionRec.Insert(false);
    //         addSPlist(sl, OptionRec);

    //         for j := 1 to 5 do begin
    //             OptionSuffixRec.Init();
    //             OptionSuffixRec."Suffix Designator" := OptionRec."Prefix Designator" + 'SD' + Format(j);
    //             OptionSuffixRec."Suffix Order" := j * 100;
    //             OptionSuffixRec.OptionID := OptionRec.Id; // this should match an Id in Option table
    //             OptionSuffixRec.Line := j * 2;
    //             OptionSuffixRec.show := false;
    //             OptionSuffixRec.Insert(false);
    //             addSPlist(sl, OptionSuffixRec, OptionRec."Suffix Order");

    //         end;
    //     end;

    //     // Insert test data into Option Suffix table
    // end;

    procedure addSPlist(var SPRec: Record SPList; OptionRec: Record Option)
    begin
        // Assuming we are handling a prefix
        SPRec.SetFilter(OptionID, Format(OptionRec.Id));
        SPRec.SetRange(Designator, OptionRec."Prefix Designator");
        if not SPRec.FindFirst() then begin
            SPRec.Init();
            SPRec.ID := SPRec.getNewID(); // This should be a unique value, consider using a number series here
            SPRec.OptionID := OptionRec.Id;
            SPRec.Prefix := true;
            SPRec.Order := OptionRec."Prefix Order";
            SPRec.Designator := OptionRec."Prefix Designator";
            // Set other fields as necessary
            SPRec.Insert();
        end;
    end;

    procedure addCCtoAssembly()
    var
        iRec: Record Item;
        aRec: Record "BOM Component";
    begin
        aRec.Reset();
        if aRec.FindSet() then begin
            repeat
                if iRec.get(aRec."No.") then begin

                    aRec.ccID := iRec."Item Category Id";
                    aRec.catagory := iRec."Item Category Code";
                    aRec.Modify();
                end;
            until aRec.Next() = 0;
        end;
    end;

    procedure addSPlist(var SPRec: Record SPList; OptionSuffixRec: Record "Option Suffix"; SO: Integer)
    begin
        // Handling a suffix



        // Update fields if necessary
        // SPRec.Reset();
        // SPRec.SetFilter(OptionID, Format(OptionSuffixRec.OptionID));
        // SPRec.SetRange(Designator, OptionSuffixRec."Suffix Designator");
        // if not SPRec.FindFirst() then begin
        SPRec.Init();
        SPRec.ID := SPRec.getNewID(); // This should be a unique value, consider using a number series here
        SPRec.OptionID := OptionSuffixRec.OptionID;
        SPRec.Prefix := false;
        SPRec.Order := SO;
        SPRec.Designator := OptionSuffixRec."Suffix Designator";
        // Set other fields as necessary
        SPRec.Insert();
        // end;
    end;

    procedure assTest()
    var
        ioRec: Record "Item Option Line";
        oRec: Record Option;
        osRec: Record "Option Suffix";
        aRec: Record "Option Assembly Line";
        spRec: Record SPList;
    begin
        oRec.Init();
        oRec.Id := 1000;
        oRec.Name := 'Networking';
        oRec."Prefix Designator" := 'N';
        oRec."Prefix Order" := 1000;
        oRec."Suffix Order" := 200;
        oRec.Insert();
        addSPlist(spRec, oRec);
        osRec.Init();
        osRec."Suffix Designator" := '/5/110';
        osRec.Line := 0001;
        osRec.OptionID := 1000;
        osRec."Suffix Order" := 200;
        osRec.AssemblyChange := 1000;
        osRec.Insert();
        addSPlist(spRec, osRec, oRec."Suffix Order");
        aRec.Init();
        aRec.ID := 1000;
        aRec."Option ID" := 1000;
        aRec.No := '110-POWER-SUPPLY';
        aRec.Description := '110 TRANSFORMERS WITH SMALLER & LIGHTER PLUGIN';
        aRec."Line No." := 0001;
        aRec.Qty := 1;
        aRec.Designator := '/5/110';
        aRec.Insert();

        ioRec.Init();
        ioRec.lID := 1000;
        ioRec."Line No." := 0001;
        ioRec."ItemNo." := 'LDCBS1X2-TNC';
        ioRec.OptionID := 1000;
        ioRec.OptionName := 'Networking';
        ioRec."Price Change" := 100;
        ioRec.Caption := 'Networking';
        ioRec.Insert();

    end;
}
