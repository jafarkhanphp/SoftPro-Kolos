// table 50012 "Custom Sales Line"
// {
//     DataClassification = ToBeClassified;

//     fields
//     {
//         field(1; "Document No."; Code[20])
//         {
//             DataClassification = CustomerContent;
//         }
//         field(2; "Line No."; Integer)
//         {
//             DataClassification = SystemMetadata;
//         }
//         field(3; "Item No."; Code[20])
//         {
//             DataClassification = ToBeClassified; // Replaced ProductContent
//         }
//         field(4; Quantity; Decimal)
//         {
//             DataClassification = SystemMetadata;
//         }
//         field(5; "Unit Price"; Decimal)
//         {
//             DataClassification = ToBeClassified;
//         }
//         field(6; "Line Amount"; Decimal)
//         {
//             DataClassification = ToBeClassified;
//             Editable = false;
//         }
//     }

//     keys
//     {
//         key(PK; "Document No.", "Line No.")
//         {
//             Clustered = true;
//         }
//     }
// }
