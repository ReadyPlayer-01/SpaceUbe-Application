function Login() {
  return (
    <form id="login-form">
        <table>
            <tr>
                <td id="enter">
                    <button type="submit" id="enter-button">Enter</button>
                </td>
                <td id="login-input">
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
                        <tr>
                            <td>
                                <button type="button" id="new-account"><em>Create new account</em></button>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </form>
  )
}

export default Login
