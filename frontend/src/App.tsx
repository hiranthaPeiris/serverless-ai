// import { useState } from 'react'
// import reactLogo from './assets/react.svg'
// import viteLogo from '/vite.svg'
// import './App.css'

// function App() {
//   const [count, setCount] = useState(0)

//   return (
//     <>
//       <div>
//         <a href="https://vitejs.dev" target="_blank">
//           <img src={viteLogo} className="logo" alt="Vite logo" />
//         </a>
//         <a href="https://react.dev" target="_blank">
//           <img src={reactLogo} className="logo react" alt="React logo" />
//         </a>
//       </div>
//       <h1>Vite + React</h1>
//       <div className="card">
//         <button onClick={() => setCount((count) => count + 1)}>
//           count is {count}
//         </button>
//         <p>
//           Edit <code>src/App.tsx</code> and save to test HMR
//         </p>
//       </div>
//       <p className="read-the-docs">
//         Click on the Vite and React logos to learn more
//       </p>
//     </>
//   )
// }

// export default App






// import { Amplify, Auth } from "aws-amplify";
// import { withAuthenticator } from "@aws-amplify/ui-react";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import "./index.css";
import Layout from "./routes/layout";
import Documents from "./routes/documents";
// import Chat from "./routes/chat";

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
export default App
// export default withAuthenticator(App, { hideSignUp: true });