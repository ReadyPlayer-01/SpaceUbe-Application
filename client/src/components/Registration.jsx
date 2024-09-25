import { Link } from 'react-router-dom';

function Registration() {
  return (
    <form id="registration-form">
        <table>
            <tr>
                <td id="register">
                    <Link to="/login">
                        <button type="submit" id="register-button">Register</button>
                    </Link>
                </td>
                <td id="registration-input">
                    <table>
                        <tr>
                            <td>
                                <input type="text" id="username" placeholder="Username" autoComplete="off" required></input>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <input type="password" id="password" placeholder="Password" required></input>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </form>
  )
}

export default Registration;
