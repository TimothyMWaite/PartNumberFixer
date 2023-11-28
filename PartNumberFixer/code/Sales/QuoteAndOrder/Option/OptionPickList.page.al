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
                field(SalesHeadID; rec.shID){
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
                field(Selection; rec.selection){
                  ApplicationArea = All;
                }
            }
        }
    }
}
enum 50137 SalesLineEnum
{


    Extensible = true;


    // Add more values for each sales line.

    caption = 'Sales Lines';
}