// table 50011 "Custom Sales Header"
// {
//     DataClassification = ToBeClassified;

//     fields
//     {
//         field(1; "No."; Code[20])
//         {
//             DataClassification = CustomerContent;
//         }
//         field(2; "Customer No."; Code[20])
//         {
//             DataClassification = CustomerContent;
//         }
//         field(3; "Order Date"; Date)
//         {
//             DataClassification = SystemMetadata;
//         }
//         field(4; "Total Amount"; Decimal)
//         {
//             DataClassification = ToBeClassified; // Replaced FinancialData
//         }
//     }

//     keys
//     {
//         key(PK; "No.")
//         {
//             Clustered = true;
//         }
//     }
// }
