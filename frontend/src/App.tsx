import { createBrowserRouter, RouterProvider } from "react-router-dom";
import "./index.css";
import Layout from "./routes/layout";
import Documents from "./routes/documents";

import { Amplify } from 'aws-amplify';
import amplifyconfig from './amplifyconfiguration.json';
Amplify.configure(amplifyconfig);

import { withAuthenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
// import { type AuthUser } from "aws-amplify/auth";
// import { type UseAuthenticator } from "@aws-amplify/ui-react-core";


// export default withAuthenticator(App);
// Amplify.configure({
//   Auth: {
//     userPoolId: import.meta.env.VITE_USER_POOL_ID,
//     userPoolWebClientId: import.meta.env.VITE_USER_POOL_CLIENT_ID,
//     region: import.meta.env.VITE_API_REGION,
//   },
//   API: {
//     endpoints: [
//       {
//         name: "serverless-pdf-chat",
//         endpoint: import.meta.env.VITE_API_ENDPOINT,
//         region: import.meta.env.VITE_API_REGION,
//         custom_header: async () => {
//           return {
//             Authorization: `Bearer ${(await Auth.currentSession())
//               .getIdToken()
//               .getJwtToken()}`,
//           };
//         },
//       },
//     ],
//   },
// });

let router = createBrowserRouter([
  {
    path: "/",
    element: <Layout />,
    children: [
      {
        index: true,
        Component: Documents,
      }
      // ,
      // {
      //   path: "/doc/:documentid/:conversationid",
      //   Component: Chat,
      // },
    ],
  },
]);

function App() {
  return <RouterProvider router={router} />;
}

// export default App
export default withAuthenticator(App, { hideSignUp: true });