import {
  BrowserRouter,
  Routes,
  Route,
} from "react-router-dom";

import ReviewScreen
from "./pages/ReviewPage";

function App() {

  return (

    <BrowserRouter>

      <Routes>

        <Route

          path="/review"

          element={<ReviewScreen />}
        />

      </Routes>

    </BrowserRouter>
  );
}

export default App;