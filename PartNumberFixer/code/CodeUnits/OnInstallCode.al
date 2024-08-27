codeunit 50103 "My Install Codeunit"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        PopulateIntermediaryTable();
        // InsertTestData();
        // assTest();
        optionTest();
    end;

    procedure PopulateIntermediaryTable()
    var
        ItemRec: Record Item;
        IntermediaryPartRec: Record "Intermediary Part Table";
    begin

        // Loop through all items and add to intermediary table
        if ItemRec.FindSet then
            repeat
                if not IntermediaryPartRec.Get(ItemRec."PartNumber") then begin
                    IntermediaryPartRec.Init();
                    if ItemRec.PartNumber = '' then begin

                        ItemRec.PartNumber := ItemRec."No.";
                        ItemRec.Modify();

                    end;
                    IntermediaryPartRec."PartNumber" := ItemRec."PartNumber";
                    IntermediaryPartRec."Item ID" := ItemRec."No.";
                    IntermediaryPartRec."Item Description" := ItemRec."Description";
                    // Populate additional fields here, if any
                    IntermediaryPartRec.Insert();
                end;
            until ItemRec.Next = 0;
        addCCtoAssembly();
        IntermediaryPartRec.SETCURRENTKEY("PartNumber");
        IntermediaryPartRec.ASCENDING(TRUE);
    end;

    procedure optionTest();
    var
        iRec: Record Item;
    begin
        InsertRecords(
    1000,
    'Networking',
    'N',
    1000,
    200,
    '/XX/110',
    '/5/220'
);
        if iRec.get('LDCBS1X2-TNC') then begin
            iRec.ports := 3;
            iRec.opts := true;
            iRec."Item Type" := ItemTypes::"Non-RackMount";
            iRec.Modify();
        end;
    end;
    // procedure InsertTestData()
    // var
    //     OptionRec: Record "Option";
    //     sl: Record SPList;
    //     OptionSuffixRec: Record "Option Designators";
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
    //             OptionSuffixRec."Designator" := OptionRec."Prefix Designator" + 'SD' + Format(j);
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

    // procedure addSPlist(var SPRec: Record SPList; OptionRec: Record Option)
    // begin
    //     // Assuming we are handling a prefix
    //     SPRec.SetFilter(OptionID, Format(OptionRec.Id));
    //     // SPRec.SetRange(Designator, OptionRec."Prefix Designator");
    //     if not SPRec.FindFirst() then begin
    //         SPRec.Init();
    //         SPRec.ID := SPRec.getNewID(); // This should be a unique value, consider using a number series here
    //         SPRec.OptionID := OptionRec.Id;
    //         SPRec.inFront := true;
    //         // SPRec.Order := OptionRec."Prefix Order";
    //         // SPRec.Designator := OptionRec."Prefix Designator";
    //         // Set other fields as necessary
    //         SPRec.Insert();
    //     end;
    // end;

    procedure addCCtoAssembly()
    var
        iRec: Record Item;
        aRec: Record "BOM Component";
    begin
        aRec.Reset();
        if aRec.FindSet() then begin
            repeat
                if iRec.get(aRec."No.") then begin

                    aRec."PartType" := iRec."PartType";
                    aRec.Modify();
                end;
            until aRec.Next() = 0;
        end;
    end;

    // procedure addSPlist(var SPRec: Record SPList; OptionSuffixRec: Record "Option Designators"; SO: Integer)
    // begin
    //     // Handling a suffix



    //     // Update fields if necessary
    //     // SPRec.Reset();
    //     // SPRec.SetFilter(OptionID, Format(OptionSuffixRec.OptionID));
    //     // SPRec.SetRange(Designator, OptionSuffixRec."Designator");
    //     // if not SPRec.FindFirst() then begin
    //     SPRec.Init();
    //     SPRec.ID := SPRec.getNewID(); // This should be a unique value, consider using a number series here
    //     SPRec.OptionID := OptionSuffixRec.OptionID;
    //     SPRec.inFront := false;
    //     SPRec.Order := SO;
    //     SPRec.Designator := OptionSuffixRec."Designator";
    //     // Set other fields as necessary
    //     SPRec.Insert();
    //     // end;
    // end;

    // procedure assTest()
    // var
    //     // ioRec: Record "Item Option Line";
    //     oRec: Record Option;
    //     iRec: Record Item;
    //     osRec: Record "Option Designators";
    //     // aRec: Record "Option Assembly Line";
    //     spRec: Record SPList;
    // begin
    //     oRec.Init();
    //     oRec.Id := 1000;
    //     oRec.Name := 'Networking';
    //     // oRec."Prefix Designator" := 'N';
    //     // oRec."Prefix Order" := 1000;
    //     // oRec."Suffix Order" := 200;
    //     oRec.Insert();
    //     addSPlist(spRec, oRec);
    //     osRec.Init();
    //     osRec."Designator" := '/5/110';
    //     // osRec.Line := 0001;
    //     osRec.OptionID := 1000;
    //     // osRec."Suffix Order" := 200;
    //     // osRec.No := '110-POWER-SUPPLY';
    //     // osRec.AddedPartDesc := '110 TRANSFORMERS WITH SMALLER & LIGHTER PLUGIN';
    //     // osRec.Qty := 1;
    //     // osRec.AssemblyChange := 1000;
    //     // osRec."Per Port" := false;
    //     osRec.Insert();
    //     addSPlist(spRec, osRec, osRec."Order");
    //     // aRec.Init();
    //     // aRec.ID := 1000;
    //     // aRec."Option ID" := 1000;

    //     // aRec."Line No." := 0001;
    //     // aRec.Designator := '/5/110';
    //     // aRec.Insert();
    //     osRec.Init();
    //     osRec."Designator" := '/5/220';
    //     // osRec.Line := 0001;
    //     osRec.OptionID := 1001;
    //     osRec.Order := 200;
    //     // osRec."Suffix Order" := 200;
    //     // osRec.No := '220-POWERSUPPLY-24V';
    //     // osRec.AddedPartDesc := 'AC/DC WALL MOUNT ADAPTER 24V 15W 220V';
    //     // osRec.Qty := 1;
    //     // osRec."Per Port" := false;
    //     // osRec.AssemblyChange := 1000;
    //     osRec.Insert();
    //     addSPlist(spRec, osRec, osRec."Order");
    // end;

    procedure insertDesignator(d: Text[40]; oID: Integer; ID: Integer; Order: Integer; atF: Boolean)
    var
        osRec: Record "Option Designators";
        i: Record Item;
    begin
        osRec.Init();
        osRec."Designator" := d;
        osRec.OptionID := oID;
        osRec.ID := ID;
        osRec.Order := Order;
        osRec.atFront := atF;
        osRec.itemType := ItemTypes::"Non-RackMount";
        if d = 'N' then begin
            osRec.PriceChange := 100;
        end else begin
            osRec.PriceChange := 0;
        end;
        if d = '/XX/110' then begin
            osRec.variable := true;
        end else begin
            osRec.variable := false;
        end;
        if osRec.Insert() then begin
            if d = '/XX/110' then begin
                osRec.variable := true;
                if i.get('110-POWER-SUPPLY') then begin
                    insertAss(oID, ID, d, Order, i."No.", i.Description, 1, true);
                end;
            end;
            if d = '/5/220' then begin
                osRec.variable := false;
                if i.get('220-POWERSUPPLY-24V') then begin
                    insertAss(oID, ID, d, Order, i."No.", i.Description, 1, false);
                end;
            end;
        end;

    end;

    procedure InsertRecords(
        OptionID: Integer;
        Name: Text[50];
        PrefixDesignator: Text[10];
        PrefixOrder: Integer;
        SuffixOrder: Integer;
        SuffixDesignator1: Text[10];
        SuffixDesignator2: Text[10]
        )
    var
        oRec: Record Option;
        iRec: Record Item;
    begin
        oRec.Init();
        oRec.Id := OptionID;
        oRec.Name := Name;
        oRec."Item Type" := ItemTypes::"Non-RackMount";
        oRec.Required := true;
        // oRec."Price Change" := 100;
        oRec.Insert();
        insertDesignator(PrefixDesignator, OptionID, 1000, PrefixOrder, true);
        insertDesignator(SuffixDesignator1, OptionID, 1001, SuffixOrder, false);
        insertDesignator(SuffixDesignator2, OptionID, 1002, SuffixOrder, false);
    end;

    procedure insertAss(
        OptionID: Integer;
        desID: Integer;
        Designator: Text[10];
        Order: Integer;
        No: Text[20];
        AddedPartDesc: Text[50];
        Qty: Integer;
        PerPort: Boolean
        )
    var
        irec: Record Item;
        bom: Record "BOM Component";
        aRec: Record "Option Assembly Line";
    begin
        aRec.Init();
        aRec.ID := aRec.getNewID();
        aRec."Option ID" := OptionID;
        aRec.DesID := desID;
        aRec.Designator := Designator;
        aRec.No := No;
        aRec."Part No" := No;
        aRec.Description := AddedPartDesc;
        aRec.Qty := Qty;
        aRec.replacePart := true;
        aRec.replacesPartType := partTypes::Board;
        if irec.get('GPS-LDCBS1X2-LO1') then begin
            irec.PartType := partTypes::Board;
            irec.Modify();
            bom.reset();
            bom.SetFilter("Parent Item No.", 'LDCBS1X2-TNC');
            bom.SetFilter("No.", 'GPS-LDCBS1X2-LO1');
            if bom.FindFirst() then begin
                bom.PartType := partTypes::Board;
            end;
        end;
        aRec."Per Port" := PerPort;
        aRec.Insert();
    end;
}
