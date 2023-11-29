page 50136 OptionLineList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = OptionLine;


    layout
    {
        area(Content)
        {
            field(PartNum; rec.pn)
            {
                ApplicationArea = All;
                AssistEdit = true;
                TableRelation = "Sales Line".PartNo;

            }
            repeater("Options")
            {

                field(Id; rec.Id)
                {
                    ApplicationArea = All;

                }
                field(SalesHeadID; rec.docID)
                {
                    ApplicationArea = All;
                }
                field(optionId; rec.oID)
                {
                    ApplicationArea = All;

                }
                field(OptionName; rec.oName)
                {
                    ApplicationArea = All;

                }
                //selection fields
                field("Start Selection"; rec.preSelection)
                {
                    ApplicationArea = All;
                    TableRelation = SPList.Designator where(OptionID = field(oID), prefix = const(true));
                }
                field("End Selection"; rec.sufSelection)
                {
                    ApplicationArea = All;
                    TableRelation = SPList.Designator where(OptionID = field(oID), prefix = const(false));


                }


            }
        }
    }

    trigger OnOpenPage()
    begin

    end;

    procedure setSH(s: Record "Sales Order Entity Buffer")
    begin
        shRec := s;
    end;

    procedure setI(i: Record "Sales Line")
    var
        item: Record Item;
    begin
        if item.get(i."No.") then begin
            iRec := item;
        end;
        slRec := i;
    end;

    procedure getPN(): Text[100]
    begin
        exit(fPN);
    end;

    procedure getOptions(i: Record Item)
    var
        oLRec: Record OptionLine;
        ioRec: Record "Item Option Line";
        sp: Record "SPList";
        oRec: Record "Option";
    begin
        ioRec.Reset();
        ioRec.setFilter("ItemNo.", i."No.");
        if ioRec.FindSet() then begin
            repeat
                sp.Reset();
                sp.SetFilter(OptionID, Format(ioRec.OptionID));
                if sp.FindSet() then begin
                    repeat
                        if sp.prefix then begin

                        end else begin

                        end;
                    until spRec.Next() = 0;
                end;
            until ioRec.Next() = 0;
        end;


    end;

    var
        iRec: Record Item;
        slRec: Record "Sales Line";
        shRec: Record "Sales Order Entity Buffer";
        spRec: Record SPList temporary;
        fPN: Text[200];

}
enum 50137 SalesLineEnum
{


    Extensible = true;


    // Add more values for each sales line.

    caption = 'Sales Lines';
}