codeunit 50104 "OP Page Manager"
{
    procedure openPickPage(i: Record "Sales Line"): Text[100]
    var
        lRec, ol : Record OptionLine;
        sRec: Record SPList;
        ioRec: Record "Item Option Line";
        slRec: Record "Sales Line";
        opPage: Page OptionLineList;
        pn: Text[200];
        selObj: JsonObject;
    begin
        ioRec.Reset();
        ioRec.SetFilter("ItemNo.", i."No.");
        ol.Reset();
        ol.SetRange(iID, i."No.");
        ol.SetFilter(line, Format(i."Line No."));
        ol.SetFilter(docID, i."Document No.");
        if not ol.FindSet() then begin
            if ioRec.FindSet() then begin
                repeat
                    lRec.Reset();
                    lRec.Init();
                    lRec.docID := i."Document No.";
                    lRec.Id := lRec.getNewID();
                    lRec.iID := ioRec."ItemNo.";
                    lRec.oID := ioRec.OptionID;
                    lRec.oName := ioRec.OptionName;
                    lRec.pn := i.PartNo;
                    lRec.line := i."Line No.";
                    lRec.Insert();
                until ioRec.Next() = 0;
            end;
        end;
        slRec.SetFilter("Document No.", i."Document No.");
        if slRec.FindSet() then begin
            repeat
                if selObj.Contains('LineNo') OR selObj.Contains('PartNo') then begin
                    selObj.Replace('LineNo', slRec."Line No.");
                    selObj.Replace('PartNo', slRec.PartNo);
                end else begin

                    selObj.Add('LineNo', slRec."Line No.");
                    selObj.Add('PartNo', slRec.PartNo);
                end;

                selList.Add(selObj);
            until slRec.Next() = 0;
        end;

        lRec.Reset();
        lRec.SetRange(iID, i."No.");
        lRec.SetFilter(line, Format(i."Line No."));
        lRec.SetFilter(docID, i."Document No.");
        opPage.SetTableView(lRec);
        opPage.setList(selList);
        opPage.setI(i);
        Commit();
        if opPage.RunModal() = Action::OK then begin

            Clear(opPage);

            exit(opPage.getPN());
        end;
    end;

    procedure getOrCreateOL(i: Record "Sales Line")
    var
        ol, lRec : Record OptionLine;
        sRec: Record SPList;
        ioRec: Record "Item Option Line";
    begin

    end;

    var
        // opPage: Page OptionLineList;
        selList: JsonArray;


}